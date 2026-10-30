import { AMPSInitChannelMethod } from '../common/common';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { AMPSIInitCallback } from 'xyz.adscope.amps';

/** 原生 SDK 每个进程只初始化一次。这里只共享进行中的那一次，结果只回给还活着的引擎。 */
export class AMPSInitCoordinator {
  static initStatus: number = 0
  private static generation: number = 0
  private static pending: Array<AMPSEventManager> | undefined = undefined

  static request(engine: AMPSEventManager, start: (callback: AMPSIInitCallback) => void): void {
    if (engine.isReleased) {
      return
    }
    const status = AMPSInitCoordinator.initStatus
    if (status === 2 || status === 4) {
      engine.sendMessageToFlutter(AMPSInitChannelMethod.alreadyInit, undefined)
      return
    }
    const pending = AMPSInitCoordinator.pending
    if (pending) {
      pending.push(engine)
      engine.sendMessageToFlutter(AMPSInitChannelMethod.initializing, undefined)
      return
    }
    AMPSInitCoordinator.generation += 1
    const token = AMPSInitCoordinator.generation
    AMPSInitCoordinator.pending = [engine]
    const callback: AMPSIInitCallback = {
      initSuccess: (): void => {
        AMPSInitCoordinator.complete(token, 2, AMPSInitChannelMethod.initSuccess)
      },
      initializing: (): void => {
        if (AMPSInitCoordinator.generation !== token) {
          return
        }
        AMPSInitCoordinator.initStatus = 1
        AMPSInitCoordinator.notify(AMPSInitChannelMethod.initializing)
      },
      alreadyInit: (): void => {
        AMPSInitCoordinator.complete(token, 4, AMPSInitChannelMethod.alreadyInit)
      },
      initFailed: (code: number, message: string): void => {
        AMPSInitCoordinator.complete(token, 3, AMPSInitChannelMethod.initFailed, {
          code: code,
          message: message
        } as ESObject)
      }
    }
    AMPSInitCoordinator.initStatus = 1
    try {
      start(callback)
    } catch (error) {
      AMPSInitCoordinator.complete(token, 3, AMPSInitChannelMethod.initFailed, {
        code: -1,
        message: error instanceof Error ? error.message : `${error}`
      } as ESObject)
    }
  }

  static detach(engine: AMPSEventManager): void {
    const pending = AMPSInitCoordinator.pending
    if (!pending) {
      return
    }
    AMPSInitCoordinator.pending = pending.filter((item: AMPSEventManager) => item !== engine)
  }

  private static notify(method: string, args?: ESObject): void {
    const pending = AMPSInitCoordinator.pending ?? []
    pending.forEach((engine: AMPSEventManager) => {
      if (!engine.isReleased) {
        engine.sendMessageToFlutter(method, args)
      }
    })
  }

  private static complete(token: number, status: number, method: string, args?: ESObject): void {
    if (AMPSInitCoordinator.generation !== token) {
      return
    }
    AMPSInitCoordinator.generation += 1
    AMPSInitCoordinator.initStatus = status
    const pending = AMPSInitCoordinator.pending ?? []
    AMPSInitCoordinator.pending = undefined
    pending.forEach((engine: AMPSEventManager) => {
      if (!engine.isReleased) {
        engine.sendMessageToFlutter(method, args)
      }
    })
  }
}

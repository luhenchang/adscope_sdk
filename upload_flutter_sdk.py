#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Flutter SDK 版本上传脚本。

用法：
    ./upload_flutter_sdk.py --dry-run
    ./upload_flutter_sdk.py

默认会按后端 Postman collection 的 /sdk/upload/flutter 接口，
把脚本内置的 Flutter 版本数组以 application/json 方式提交。
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from urllib import error, request


UPLOAD_URL = "http://m-new-test.adscope.com.cn/api/product/mediation/sdk/upload/flutter"

DEFAULT_FLUTTER_VERSIONS = [
    {
        "version": "0.1.7",
        "downloadUrl": "https://pub.dev/packages/adscope_sdk",
        "fileSize": 8600263,
        "flutterUpdateTime": "2025-06-04 11:30:00",
        "supportedSdkVersions": "Android ≥ v5.1.2.6, iOS ≥ v5.1.2.3",
    }
]


def default_flutter_versions() -> list[dict[str, object]]:
    """返回默认 Flutter 版本参数。"""
    return [dict(item) for item in DEFAULT_FLUTTER_VERSIONS]


def load_payload(json_path: Path | None) -> list[dict[str, object]]:
    """读取上传 payload；未指定文件时使用默认参数。"""
    if json_path is None:
        return default_flutter_versions()

    with json_path.expanduser().open("r", encoding="utf-8") as handle:
        payload = json.load(handle)
    if not isinstance(payload, list):
        raise ValueError("Flutter 上传参数必须是 JSON 数组")
    return payload


def encode_payload(payload: list[dict[str, object]]) -> bytes:
    """编码 JSON 请求体。"""
    return json.dumps(payload, ensure_ascii=False).encode("utf-8")


def upload_flutter_versions(upload_url: str, payload: list[dict[str, object]]) -> str:
    """调用 Flutter 版本上传接口，并返回服务端响应文本。"""
    body = encode_payload(payload)
    http_request = request.Request(
        upload_url,
        data=body,
        method="POST",
        headers={
            "Content-Type": "application/json; charset=utf-8",
            "Content-Length": str(len(body)),
        },
    )

    try:
        with request.urlopen(http_request, timeout=60) as response:
            return response.read().decode("utf-8", errors="replace")
    except error.HTTPError as exc:
        response_body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"上传失败，HTTP {exc.code}：{response_body}") from exc
    except error.URLError as exc:
        raise RuntimeError(f"无法连接上传接口：{exc.reason}") from exc


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="上传 Flutter SDK 版本信息")
    parser.add_argument("--url", default=UPLOAD_URL, help="上传接口地址")
    parser.add_argument("--json", type=Path, help="自定义 Flutter 版本 JSON 数组文件")
    parser.add_argument("--dry-run", action="store_true", help="只打印请求参数，不真正请求接口")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    payload = load_payload(args.json)

    print("即将上传 Flutter SDK 版本信息：")
    print(f"  上传地址: {args.url}")
    print("  JSON 请求体:")
    print(json.dumps(payload, ensure_ascii=False, indent=2))

    if args.dry_run:
        print("\n当前是 dry-run，只检查参数，不执行上传。")
        return 0

    print("\n开始上传...")
    response_text = upload_flutter_versions(args.url, payload)
    print("服务端响应：")
    print(response_text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

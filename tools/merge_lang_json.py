#!/usr/bin/env python3
"""Merge tools/lang/*.json into Localizable.xcstrings and extend InfoPlist.xcstrings."""
from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
XC_PATH = ROOT / "Opelog" / "Resources" / "Localizable.xcstrings"
IP_PATH = ROOT / "Opelog" / "Resources" / "InfoPlist.xcstrings"

LANG_FILES: dict[str, pathlib.Path] = {
    "de": ROOT / "tools" / "lang" / "de.json",
    "it": ROOT / "tools" / "lang" / "it.json",
    "pt-BR": ROOT / "tools" / "lang" / "pt-BR.json",
    "id": ROOT / "tools" / "lang" / "id.json",
    "vi": ROOT / "tools" / "lang" / "vi.json",
    "th": ROOT / "tools" / "lang" / "th.json",
    "zh-Hans": ROOT / "tools" / "lang" / "zh-Hans.json",
}

# Align 6-month / 1-year presets with product copy (overrides agent JSON if needed).
DAY_PRESET_180: dict[str, str] = {
    "en": "6 months",
    "ja": "6ヶ月",
    "ko": "6개월",
    "zh-Hant": "6 個月",
    "es": "6 meses",
    "fr": "6 mois",
    "de": "6 Monate",
    "it": "6 mesi",
    "pt-BR": "6 meses",
    "id": "6 bulan",
    "vi": "6 tháng",
    "th": "6 เดือน",
    "zh-Hans": "6 个月",
}

DAY_PRESET_365: dict[str, str] = {
    "en": "1 year",
    "ja": "1年",
    "ko": "1년",
    "zh-Hant": "1 年",
    "es": "1 año",
    "fr": "1 an",
    "de": "1 Jahr",
    "it": "1 anno",
    "pt-BR": "1 ano",
    "id": "1 tahun",
    "vi": "1 năm",
    "th": "1 ปี",
    "zh-Hans": "1 年",
}

ALL_APP_LANGS: list[str] = [
    "en",
    "ja",
    "ko",
    "zh-Hant",
    "zh-Hans",
    "es",
    "fr",
    "de",
    "it",
    "pt-BR",
    "id",
    "vi",
    "th",
]

MEMO_WITH_LABEL_FORMAT: dict[str, str] = {lang: "%1$@: %2$@" for lang in ALL_APP_LANGS}

# Legacy catalog key used by some tooling; keep all locales aligned.
LEGACY_MEMO_FORMAT_KEY = "%@: %@"

USED_FOR_ONE_DAY: dict[str, str] = {
    "en": "Used for 1 day",
    "ja": "1日間使用",
    "ko": "1일 사용",
    "zh-Hant": "已使用 1 天",
    "es": "Usado durante 1 día",
    "fr": "Utilisé pendant 1 jour",
    "de": "1 Tag genutzt",
    "it": "Usato per 1 giorno",
    "pt-BR": "Usado por 1 dia",
    "id": "Digunakan selama 1 hari",
    "vi": "Đã dùng trong 1 ngày",
    "th": "ใช้ไป 1 วัน",
    "zh-Hans": "已使用 1 天",
}

INFOPLIST_CAMERA: dict[str, str] = {
    "en": "Opelog uses the camera so you can take photos of items you want to remember.",
    "ja": "Opelogは、記録したいアイテムの写真を撮影するためにカメラを使用します。",
    "ko": "Opelog은 기억하고 싶은 아이템의 사진을 촬영하기 위해 카메라를 사용합니다.",
    "zh-Hant": "Opelog 會使用相機，讓你拍攝想記錄的項目照片。",
    "es": "Opelog usa la cámara para que puedas hacer fotos de los artículos que quieres recordar.",
    "fr": "Opelog utilise l’appareil photo pour vous permettre de prendre des photos des articles à mémoriser.",
    "de": "Opelog nutzt die Kamera, damit du Fotos von Artikeln aufnehmen kannst, die du dir merken möchtest.",
    "it": "Opelog usa la fotocamera per permetterti di scattare foto degli articoli che vuoi ricordare.",
    "pt-BR": "O Opelog usa a câmera para você tirar fotos dos itens que quer lembrar.",
    "id": "Opelog memakai kamera agar kamu bisa memotret barang yang ingin kamu ingat.",
    "vi": "Opelog dùng camera để bạn chụp ảnh các món đồ muốn ghi nhớ.",
    "th": "Opelog ใช้กล้องเพื่อให้คุณถ่ายรูปสิ่งของที่อยากจดจำ",
    "zh-Hans": "Opelog 使用相机，以便你拍摄想记录的物品照片。",
}

INFOPLIST_PHOTOS: dict[str, str] = {
    "en": "Opelog uses your photo library so you can add photos of items you want to remember.",
    "ja": "Opelogは、記録したいアイテムの写真を追加するために写真ライブラリを使用します。",
    "ko": "Opelog은 기억하고 싶은 아이템의 사진을 추가하기 위해 사진 보관함을 사용합니다.",
    "zh-Hant": "Opelog 會使用你的照片圖庫，以加入想記錄的項目照片。",
    "es": "Opelog usa tu biblioteca de fotos para que puedas añadir fotos de los artículos que quieres recordar.",
    "fr": "Opelog utilise votre photothèque pour vous permettre d’ajouter des photos des articles à mémoriser.",
    "de": "Opelog nutzt deine Fotomediathek, damit du Fotos von Artikeln hinzufügen kannst, die du dir merken möchtest.",
    "it": "Opelog usa la tua libreria foto per permetterti di aggiungere foto degli articoli che vuoi ricordare.",
    "pt-BR": "O Opelog usa sua biblioteca de fotos para você adicionar fotos dos itens que quer lembrar.",
    "id": "Opelog memakai pustaka foto agar kamu bisa menambahkan foto barang yang ingin kamu ingat.",
    "vi": "Opelog dùng thư viện ảnh để bạn thêm ảnh các món đồ muốn ghi nhớ.",
    "th": "Opelog ใช้คลังภาพเพื่อให้คุณเพิ่มรูปสิ่งของที่อยากจดจำ",
    "zh-Hans": "Opelog 使用你的照片图库，以便添加想记录的物品照片。",
}


def _set_unit(data: dict, key: str, lang: str, value: str) -> None:
    entry = data["strings"].setdefault(key, {})
    entry.setdefault("localizations", {})
    entry["localizations"][lang] = {"stringUnit": {"state": "translated", "value": value}}


def merge_localizable() -> None:
    data = json.loads(XC_PATH.read_text(encoding="utf-8"))
    strings = data["strings"]

    for lang, path in LANG_FILES.items():
        tr = json.loads(path.read_text(encoding="utf-8"))
        for key, val in tr.items():
            _set_unit(data, key, lang, val)

    for lang, val in DAY_PRESET_180.items():
        _set_unit(data, "day_preset_180", lang, val)
    for lang, val in DAY_PRESET_365.items():
        _set_unit(data, "day_preset_365", lang, val)
    for lang, val in USED_FOR_ONE_DAY.items():
        _set_unit(data, "used_for_one_day", lang, val)
    for lang, val in MEMO_WITH_LABEL_FORMAT.items():
        _set_unit(data, "memo_with_label_format", lang, val)
    for lang, val in MEMO_WITH_LABEL_FORMAT.items():
        _set_unit(data, LEGACY_MEMO_FORMAT_KEY, lang, val)

    XC_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("Updated", XC_PATH)


def merge_infoplist() -> None:
    data = json.loads(IP_PATH.read_text(encoding="utf-8"))
    langs = list(INFOPLIST_CAMERA.keys())
    bundle_name = {lang: "Opelog" for lang in langs}
    for key, table in [
        ("CFBundleName", bundle_name),
        ("NSCameraUsageDescription", INFOPLIST_CAMERA),
        ("NSPhotoLibraryUsageDescription", INFOPLIST_PHOTOS),
    ]:
        entry = data["strings"].setdefault(key, {})
        entry.setdefault("localizations", {})
        for lang in langs:
            entry["localizations"][lang] = {"stringUnit": {"state": "translated", "value": table[lang]}}
    IP_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("Updated", IP_PATH)


def main() -> None:
    merge_localizable()
    merge_infoplist()


if __name__ == "__main__":
    main()

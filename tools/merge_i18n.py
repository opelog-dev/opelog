#!/usr/bin/env python3
"""Merge tab-separated translations into Opelog/Resources/Localizable.xcstrings."""
from __future__ import annotations

import csv
import io
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
XC_PATH = ROOT / "Opelog" / "Resources" / "Localizable.xcstrings"
PARTS = [
    ROOT / "tools" / "i18n_part1.tsv",
    ROOT / "tools" / "i18n_part2.tsv",
    ROOT / "tools" / "i18n_part3.tsv",
]
LANGS = ["en", "ja", "ko", "zh-Hant", "es", "fr"]

# Embedded TSV (tab-separated). Use literal \n in cells for newlines.
TSV_BULK = r"""key	en	ja	ko	zh-Hant	es	fr
accessibility_add_item	Add Item	アイテムを追加	아이템 추가	新增項目	Añadir artículo	Ajouter un article
action_add_item	Add Item	アイテムを追加	아이템 추가	新增項目	Añadir artículo	Ajouter un article
action_add_photo	Add Photo	写真を追加	사진 추가	新增照片	Añadir foto	Ajouter une photo
action_cancel	Cancel	キャンセル	취소	取消	Cancelar	Annuler
action_choose_from_library	Choose from Library	ライブラリから選ぶ	라이브러리에서 선택	從相簿選擇	Elegir de la biblioteca	Choisir dans la photothèque
action_clear_photo	Remove Photo	写真を削除	사진 삭제	刪除照片	Eliminar foto	Supprimer la photo
action_delete	Delete	削除	삭제	刪除	Eliminar	Supprimer
action_delete_item	Delete Item	アイテムを削除	아이템 삭제	刪除項目	Eliminar artículo	Supprimer l’article
action_edit_item	Edit Item	アイテムを編集	아이템 편집	編輯項目	Editar artículo	Modifier l’article
action_mark_favorite	Mark as Favorite	お気に入りにする	즐겨찾기에 추가	加入最愛	Marcar como favorito	Marquer comme favori
action_mark_finished	Done	完了	완료	完成	Listo	Terminé
action_ok	OK	OK	확인	確定	OK	OK
action_remove_favorite	Remove Favorite	お気に入りを解除	즐겨찾기 해제	取消最愛	Quitar favorito	Retirer des favoris
action_save	Save	保存	저장	儲存	Guardar	Enregistrer
action_take_photo	Take Photo	写真を撮る	사진 촬영	拍照	Tomar foto	Prendre une photo
add_more_photos	Multiple photos	複数写真	여러 장의 사진	多張照片	Varias fotos	Plusieurs photos
add_more_photos_with_premium	Add more photos with Premium	Premiumで写真を複数枚追加できます	Premium으로 사진을 여러 장 추가할 수 있습니다	使用 Premium 可加入多張照片	Añade más fotos con Premium	Ajoutez plus de photos avec Premium
after_use_section	After use	使い終わったあと	사용 후	使用後	Después de usar	Après usage
alert_delete_message	This item and its photos will be removed from this device.	このアイテムと写真はこの端末から削除されます。	이 아이템과 사진이 이 기기에서 삭제됩니다。	此項目與照片將從此裝置移除。	Se eliminará el artículo y sus fotos de este dispositivo.	L’article et ses photos seront supprimés de cet appareil.
alert_delete_title	Delete this item?	このアイテムを削除しますか？	이 아이템을 삭제할까요？	要刪除此項目嗎？	¿Eliminar este artículo？	Supprimer cet article？
alert_mark_finished_message	It will move to your finished log. You can add a note later.	使い切りログに移動します。あとからメモを追加できます。	사용 완료 기록으로 이동합니다. 나중에 메모를 추가할 수 있습니다。	將移到用完記錄，之後仍可加入備註。	Se moverá al registro de terminados. Podrás añadir una nota después.	Il sera déplacé vers l’historique terminé. Vous pourrez ajouter une note plus tard.
alert_mark_finished_title	Mark as finished?	使い終わりにしますか？	사용 완료로 표시할까요？	要標記為用完了嗎？	¿Marcar como terminado？	Marquer comme terminé？
app_name	Opelog	Opelog	Opelog	Opelog	Opelog	Opelog
app_version_detail_format	Version %1$@ (%2$@)	バージョン %1$@（%2$@）	버전 %1$@ (%2$@)	版本 %1$@（%2$@）	Versión %1$@ (%2$@)	Version %1$@ (%2$@)
app_version_short_format	Version %@	バージョン %@	버전 %@	版本 %@	Versión %@	Version %@
archive_empty_subtitle	Finished items will appear here with gentle summaries.	使い切ったアイテムが、やさしいまとめと一緒に表示されます。	사용 완료한 아이템이 여기에 부드러운 요약과 함께 표시됩니다。	用完的項目會與摘要一起顯示在此。	Los artículos terminados aparecerán aquí con resúmenes sencillos.	Les articles terminés apparaîtront ici avec de petits récapitulatifs.
archive_empty_title	No finished items yet	まだ使い切りログはありません	아직 사용 완료 기록이 없습니다	尚無用完記錄	Aún no hay artículos terminados	Pas encore d’articles terminés
archive_filtered_empty_hint	No items match this filter. Try another chip.	この条件に合うアイテムはありません。別のバッジを試してください。	이 필터와 일치하는 아이템이 없습니다. 다른 칩을 선택해 보세요。	沒有符合此篩選的項目，請試試其他標籤。	Ningún artículo coincide con este filtro. Prueba otra etiqueta.	Aucun article ne correspond à ce filtre. Essayez une autre pastille.
archive_finished_line	Finished %@	終了: %@	완료: %@	完成：%@	Terminado %@	Terminé %@
archive_opened_line	Opened %@	開封: %@	개봉: %@	開封：%@	Abierto %@	Ouvert %@
archive_used_days_format	Used for %lld days	%lld日間使用	%lld일 사용	已使用 %lld 天	Usado durante %lld días	Utilisé pendant %lld jours
category_contact_lens	Contact Lens	コンタクト	콘택트렌즈	隱形眼鏡	Lentes de contacto	Lentilles de contact
category_daily_items	Daily Items	日用品	생활용품	日用品	Artículos diarios	Articles du quotidien
category_eye_drops	Eye Drops	目薬	안약	眼藥水	Gotas para los ojos	Collyre
category_filters	Filters	フィルター	필터	濾芯	Filtros	Filtres
category_food	Food	食品	식품	食品	Alimentos	Aliments
category_fragrance	Fragrance	香水	향수	香水	Fragancia	Parfum
category_haircare	Haircare	ヘアケア	헤어케어	護髮	Cuidado del cabello	Soin des cheveux
category_makeup	Makeup	コスメ	메이크업	彩妝	Maquillaje	Maquillage
category_medicine	Medicine	薬	의약품	藥品	Medicamentos	Médicaments
category_other	Other	その他	기타	其他	Otros	Autre
category_pet_food	Pet Food	ペットフード	반려동물 사료	寵物食品	Comida para mascotas	Nourriture pour animaux
category_razor	Razor	カミソリ	면도기	刮鬍刀	Rasuradora	Rasoir
category_skincare	Skincare	スキンケア	스킨케어	保養品	Cuidado de la piel	Soin de la peau
category_supplements	Supplements	サプリ	영양제	保健品	Suplementos	Compléments
category_toothbrush	Toothbrush	歯ブラシ	칫솔	牙刷	Cepillo de dientes	Brosse à dents
change_theme	Change Theme	テーマ変更	테마 변경	更換主題	Cambiar tema	Changer de thème
check_in_n_days	Check in %lld days	あと%lld日でチェック	%lld일 후 확인	%lld 天後檢查	Revisar en %lld días	À vérifier dans %lld jours
check_today	Check today	今日チェック	오늘 확인	今天檢查	Revisar hoy	À vérifier aujourd’hui
check_tomorrow	Check tomorrow	明日チェック	내일 확인	明天檢查	Revisar mañana	À vérifier demain
current_theme	Current Theme	現在のテーマ	현재 테마	目前主題	Tema actual	Thème actuel
day_preset_30	30 days	30日	30일	30 天	30 días	30 jours
day_preset_60	60 days	60日	60일	60 天	60 días	60 jours
day_preset_90	90 days	90日	90일	90 天	90 días	90 jours
day_preset_180	6 months	6ヶ月	6개월	6 個月	6 meses	6 mois
day_preset_365	1 year	1年	1년	1 年	1 año	1 an
day_preset_custom	Custom	カスタム	사용자 지정	自訂	Personalizado	Personnalisé
detail_favorite_toggle	Favorite	お気に入り	즐겨찾기	最愛	Favorito	Favori
detail_hint_past_estimate	Past your own check estimate	自分のチェック目安を過ぎています	본인이 설정한 확인 기준일이 지났습니다	已超過你自己設定的檢查提醒	Has superado tu propia estimación de revisión	Vous avez dépassé votre propre rappel estimé
detail_hint_replace_soon	Your check estimate is close	チェック目安が近づいています	확인 기준일이 가까워졌습니다	檢查提醒將至	Se acerca tu estimación de revisión	Votre rappel estimé approche
detail_memo_header	Memo	メモ	메모	備註	Nota	Note
detail_notification_off	Off	オフ	끔	關	Desactivado	Désactivé
detail_notification_on	On	オン	켬	開	Activado	Activé
detail_repurchase_note	Note (optional)	メモ（任意）	메모(선택)	備註（選填）	Nota (opcional)	Note (facultatif)
detail_repurchase_status	Repurchase	リピート	재구매	回購	Recompra	Rachat
detail_row_category	Category	カテゴリ	카테고리	類別	Categoría	Catégorie
detail_row_check_estimate	Check Estimate	チェック目安	확인 기준일	檢查提醒	Estimación de revisión	Rappel estimé
detail_row_days_since_opened	Days since opened	開封からの日数	개봉 후 경과 일수	開封後天數	Días desde la apertura	Jours depuis l’ouverture
detail_row_finished_date	Finished date	使い切り日	사용 완료일	完成日期	Fecha de terminado	Date de fin
detail_row_notifications	Notifications	通知	알림	通知	Notificaciones	Notifications
detail_row_opened_date	Opened Date	開封日	개봉일	開封日期	Fecha de apertura	Date d’ouverture
detail_row_remaining_estimate	Days until check	チェックまでの日数	확인까지 남은 일수	距離檢查的天數	Días hasta la revisión	Jours avant la vérification
detail_row_target_date	Check estimate date	チェック目安日	확인 기준일	檢查提醒日期	Fecha estimada de revisión	Date du rappel estimé
detail_row_usage_days	Usage days	使用日数	사용 일수	使用天數	Días de uso	Jours d’utilisation
favorite_badge	Favorite	お気に入り	즐겨찾기	最愛	Favorito	Favori
field_category	Category	カテゴリ	카테고리	類別	Categoría	Catégorie
field_days	Days	日数	일수	天數	Días	Jours
field_item_name	Item Name	アイテム名	아이템 이름	項目名稱	Nombre del artículo	Nom de l’article
field_memo	Memo	メモ	메모	備註	Nota	Note
field_notification	Notification	通知	알림	通知	Notificación	Notification
field_opened_date	Opened Date	開封日	개봉일	開封日期	Fecha de apertura	Date d’ouverture
field_optional_notes	Optional	任意	선택 사항	選填	Opcional	Facultatif
field_photo	Photo	写真	사진	照片	Foto	Photo
field_use_within	Use Within	使用目安	사용 기준	使用期限參考	Usar antes de	À utiliser sous
finished_log_empty_subtitle	When you finish an item, it will appear here with gentle summaries.	使い終わったアイテムが、やさしいまとめと一緒に表示されます。	사용을 마친 아이템이 여기에 부드러운 요약과 함께 표시됩니다。	用完的項目會與摘要一起顯示在此。	Cuando termines un artículo, aparecerá aquí con resúmenes sencillos.	Quand vous terminez un article, il apparaîtra ici avec de petits récapitulatifs.
finished_log_empty_title	No finished items yet	まだ使い切りログはありません	아직 사용 완료 기록이 없습니다	尚無用完記錄	Aún no hay artículos terminados	Pas encore d’articles terminés
finished_log_title	Finished Log	使い切りログ	사용 완료 기록	用完記錄	Registro de terminados	Historique terminé
finished_period_format	%1$@ – %2$@	%1$@〜%2$@	%1$@ – %2$@	%1$@ – %2$@	%1$@ – %2$@	%1$@ – %2$@
finished_status	Finished	使い切り	사용 완료	已用完	Terminado	Terminé
finished_summary_average_format	%d days avg	平均 %d日	평균 %d일	平均 %d 天	Promedio %d días	Moyenne %d jours
finished_summary_count_format	%d finished	使い切り %d件	완료 %d개	已用完 %d 件	%d terminados	%d terminés
finished_summary_longest_format	%d days longest	最長 %d日	최장 %d일	最長 %d 天	Hasta %d días	Plus long %d jours
footer_notifications_mvp_format	We’ll remind you on the check day at %@ (local time).	チェック当日の%@（端末の現地時間）に通知します。	확인 당일 %@(현지 시간)에 알려드립니다。	會在檢查當日的 %@（裝置當地時間）提醒。	Te recordaremos el día de revisión a %@ (hora local).	Nous vous rappellerons le jour du contrôle à %@ (heure locale).
settings_reminder_time_hint	Applies to all active items that have reminders on.	通知がオンのアクティブなアイテムに適用されます。	알림이 켜진 진행 중 아이템에 적용됩니다。	適用於已開啟通知的進行中項目。	Se aplica a los artículos activos con notificaciones activadas.	S’applique aux articles actifs dont les rappels sont activés.
footer_notifications_permission_hint	If reminders are off in Settings, notifications won’t arrive.	設定で通知がオフの場合は届きません。	설정에서 알림이 꺼져 있으면 도착하지 않습니다。	若在設定中關閉通知，將不會收到提醒。	Si las notificaciones están desactivadas en Ajustes, no llegarán.	Si les notifications sont désactivées dans Réglages, elles n’arriveront pas.
footer_photo_local	Photos stay on this device only.	写真はこの端末内だけに保存されます。	사진은 이 기기에만 저장됩니다。	照片只會存在此裝置上。	Las fotos solo se guardan en este dispositivo.	Les photos restent uniquement sur cet appareil.
footer_use_within_explanation	This is your personal check estimate—not an expiration date.	あなた自身のチェック目安です。使用期限の保証ではありません。	본인이 정한 확인 기준일이며, 유통기한을 보장하지 않습니다。	這是你自己的檢查提醒，並非有效期限保證。	Es tu estimación personal de revisión, no una fecha de caducidad.	C’est votre rappel estimé personnel, pas une date d’expiration.
home_display_hint_footer	Long-press the list for sort and filter options.	一覧を長押しで並べ替えと絞り込み。	목록을 길게 눌러 정렬과 필터。	長按列表可排序與篩選。	Mantén pulsada la lista para ordenar y filtrar.	Appui long sur la liste pour trier et filtrer.
home_empty_subtitle	Add your first opened item—photos and reminders are optional.	最初の開封アイテムを追加。写真や通知は任意です。	첫 개봉 아이템을 추가하세요. 사진과 알림은 선택 사항입니다。	加入第一個開封項目，照片與通知皆為選填。	Añade tu primer artículo abierto; fotos y recordatorios son opcionales.	Ajoutez votre premier article ouvert ; photos et rappels sont facultatifs.
home_empty_title	Nothing here yet	まだ何もありません	아직 아무것도 없습니다	尚無項目	Aún no hay nada	Rien pour l’instant
home_filter_category_all	All categories	すべてのカテゴリ	모든 카테고리	所有類別	Todas las categorías	Toutes les catégories
home_filter_category_section	Category	カテゴリ	카테고리	類別	Categoría	Catégorie
home_filter_status_all	All statuses	すべての状態	모든 상태	所有狀態	Todos los estados	Tous les statuts
home_filter_status_section	Status	状態	상태	狀態	Estado	Statut
home_search_placeholder	Search items	アイテムを検索	아이템 검색	搜尋項目	Buscar artículos	Rechercher des articles
home_sort_check_soonest	Check soonest	チェックが近い順	확인이 가까운 순	即將檢查	Revisión más próxima	Contrôle le plus proche
home_sort_opened_newest	Opened (newest)	開封が新しい順	개봉일 최신순	開封日期（最新）	Apertura (más reciente)	Ouverture (plus récent)
home_sort_opened_oldest	Opened (oldest)	開封が古い順	개봉일 오래된 순	開封日期（最舊）	Apertura (más antigua)	Ouverture (plus ancien)
home_sort_recent_created	Recently added	追加が新しい順	최근 추가순	最近新增	Recién añadidos	Ajoutés récemment
home_sort_section	Sort	並べ替え	정렬	排序	Ordenar	Trier
how_was_this_item	How was this item?	使い心地はどうでしたか？	사용感은 어땠나요？	使用心得如何？	¿Qué tal este artículo？	Comment était cet article？
memo_label	Memo	メモ	메모	備註	Nota	Note
multiple_photo_limit_title	Photo limit	写真の上限	사진 한도	照片上限	Límite de fotos	Limite de photos
multiple_photo_premium_max_message	You can add up to 5 photos per item.	1つのアイテムに追加できる写真は最大5枚です。	아이템 하나에 최대 5장의 사진을 추가할 수 있습니다。	每個項目最多可加入 5 張照片。	Puedes añadir hasta 5 fotos por artículo.	Vous pouvez ajouter jusqu’à 5 photos par article.
notif_reminder_body_format	%1$@ was opened %2$d days ago.	%1$@を開封して%2$d日経ちました。	%1$@을(를) 개봉한 지 %2$d일이 지났습니다。	%1$@ 已開封 %2$d 天。	%1$@ fue abierto hace %2$d días.	%1$@ a été ouvert il y a %2$d jours.
notif_reminder_title	Time to check this item	そろそろチェック	확인할 시간입니다	該檢查這個項目了	Es hora de revisar este artículo	Il est temps de vérifier cet article
open_app_settings	Open Settings	設定アプリで開く	설정에서 열기	開啟設定	Abrir Ajustes	Ouvrir Réglages
opened_n_days_ago	Opened %lld days ago	開封して%lld日	개봉한 지 %lld일	已開封 %lld 天	Abierto hace %lld días	Ouvert il y a %lld jours
opened_one_day_ago	Opened 1 day ago	開封して1日	개봉한 지 1일	已開封 1 天	Abierto hace 1 día	Ouvert il y a 1 jour
opened_today	Opened today	今日開封	오늘 개봉	今天開封	Abierto hoy	Ouvert aujourd’hui
past_estimate_n_days	Past estimate by %lld days	目安を%lld日過ぎています	기준일을 %lld일 지났습니다	已超過提醒 %lld 天	Estimación superada por %lld días	Estimation dépassée de %lld jours
past_estimate_one_day	Past estimate by 1 day	目安を1日過ぎています	기준일을 1일 지났습니다	已超過提醒 1 天	Estimación superada por 1 día	Estimation dépassée de 1 jour
personal_notes_section	Personal notes	自分用メモ	개인 메모	個人備註	Notas personales	Notes personnelles
premium_already_premium	You’re already Premium.	すでにPremiumです。	이미 Premium입니다。	您已啟用 Premium。	Ya tienes Premium activo.	Vous avez déjà Premium.
premium_benefit_archive	Unlimited archive	アーカイブ無制限	보관함 무제한	無限用完記錄	Historial ilimitado	Historique illimité
premium_benefit_future	Future Premium features	今後のPremium機能	향후 Premium 기능	未來 Premium 功能	Futuras funciones Premium	Futures fonctionnalités Premium
premium_benefit_items	Unlimited items	アイテム無制限	아이템 무제한	無限項目	Artículos ilimitados	Articles illimités
premium_benefit_multiple_photos	Multiple photos per item	写真を複数枚保存	아이템당 여러 장의 사진	每個項目可加入多張照片	Varias fotos por artículo	Plusieurs photos par article
premium_benefit_multiple_photos_detail	Save more photos for each item, like labels, ingredients, and finished-item photos.	ラベル、成分表、使い切り時の写真なども一緒に残せます。	라벨, 성분표, 사용 완료 사진도 함께 저장할 수 있습니다。	可一起保存標籤、成分表與用完時的照片。	Guarda más fotos de cada artículo, como etiquetas, ingredientes y fotos al terminarlo.	Enregistrez plus de photos pour chaque article, comme les étiquettes, les ingrédients et les photos une fois terminé.
premium_benefit_no_ads	No ads	広告なし	광고 없음	無廣告	Sin anuncios	Sans publicité
premium_benefit_theme	Themes	テーマ変更	테마	主題	Temas	Thèmes
premium_close	Close	閉じる	닫기	關閉	Cerrar	Fermer
premium_limit_line1	You’ve reached the free item limit.	無料プランのアイテム上限に達しました。	무료 플랜의 아이템 한도에 도달했습니다。	已達免費方案的项目上限。	Has alcanzado el límite de artículos del plan gratuito.	Vous avez atteint la limite d’articles du plan gratuit.
premium_limit_line2	Upgrade to Premium to add unlimited items.	Premiumにアップグレードすると、無制限に追加できます。	Premium으로 업그레이드하면 무제한으로 추가할 수 있습니다。	升級 Premium 即可無限新增。	Actualiza a Premium para añadir artículos ilimitados.	Passez à Premium pour ajouter des articles illimités.
premium_onetime_note	One-time purchase. No subscription.	サブスクではなく、買い切りです。	구독이 아닌 일회성 구매입니다。	一次買斷，非訂閱制。	Compra única. Sin suscripción.	Achat unique. Pas d’abonnement.
premium_pending	This purchase is pending. You’ll unlock Premium when it completes.	購入が承認待ちです。完了するとPremiumが有効になります。	구매가 대기 중입니다. 완료되면 Premium이 활성화됩니다。	購買處理中，完成後即啟用 Premium。	La compra está pendiente. Premium se activará al completarse.	L’achat est en attente. Premium se débloquera une fois terminé.
premium_purchase_failed	Purchase could not finish. Please try again.	購入に失敗しました。もう一度お試しください。	구매를 완료할 수 없습니다. 다시 시도해 주세요。	無法完成購買，請再試一次。	No se pudo completar la compra. Inténtalo de nuevo.	L’achat n’a pas pu aboutir. Réessayez.
premium_restore_button	Restore Purchase	購入を復元	구매 복원	恢復購買	Restaurar compra	Restaurer l’achat
premium_restore_empty	No purchases were found to restore.	復元できる購入が見つかりませんでした。	복원할 구매 내역을 찾을 수 없습니다。	找不到可恢復的購買。	No se encontraron compras para restaurar.	Aucun achat à restaurer.
premium_restore_success	Your purchase was restored.	購入を復元しました。	구매가 복원되었습니다。	已恢復購買。	Compra restaurada.	Achat restauré.
premium_store_unavailable	The store is temporarily unavailable.	ストアに接続できませんでした。	스토어를 일시적으로 사용할 수 없습니다。	商店暫時無法使用。	La tienda no está disponible temporalmente.	La boutique est temporairement indisponible.
premium_subtitle	Log opened items more freely.	もっと自由に、開封日を記録。	개봉일을 더 자유롭게 기록하세요。	更自由地記錄開封日期。	Registra tus productos abiertos con más libertad.	Enregistrez vos produits ouverts plus librement.
premium_theme	Premium theme	Premiumテーマ	Premium 테마	Premium 主題	Tema Premium	Thème Premium
premium_title	Opelog Premium	Opelog Premium	Opelog Premium	Opelog Premium	Opelog Premium	Opelog Premium
premium_unlock_button	Unlock Premium	Premiumを解放	Premium 잠금 해제	解鎖 Premium	Desbloquear Premium	Débloquer Premium
repurchase_buy_again	Buy Again	また買う	다시 구매	會回購	Comprar de nuevo	Racheter
repurchase_do_not_buy_again	Do Not Buy Again	リピートしない	재구매 안 함	不回購	No volver a comprar	Ne pas racheter
repurchase_filter_all	All	すべて	전체	全部	Todos	Tous
repurchase_filter_buy_again	Buy again	また買う	다시 구매	會回購	Comprar de nuevo	Racheter
repurchase_filter_do_not_buy_again	Do not buy again	リピートしない	재구매 안 함	不回購	No volver a comprar	Ne pas racheter
repurchase_filter_favorites	Favorites	お気に入り	즐겨찾기	最愛	Favoris	Favoris
repurchase_not_sure	Not Sure	まだ決めていない	아직 모름	尚未決定	No estoy seguro	Pas sûr
request_notification_permission	Request notification permission	通知の許可を求める	알림 권한 요청	要求通知權限	Solicitar permiso de notificaciones	Demander l’autorisation de notifications
save_failed_message	Could not save. Please try again.	保存できませんでした。もう一度お試しください。	저장할 수 없습니다. 다시 시도해 주세요。	無法儲存，請再試一次。	No se pudo guardar. Inténtalo de nuevo.	Impossible d’enregistrer. Réessayez.
save_failed_title	Save failed	保存に失敗	저장 실패	儲存失敗	Error al guardar	Échec de l’enregistrement
settings_display_body	Home shows your active opened items. Sort and filter from the list menu.	ホームでは進行中の開封アイテムを表示します。一覧のメニューから並べ替えと絞り込みができます。	홈에는 진행 중인 개봉 아이템이 표시됩니다. 목록 메뉴에서 정렬과 필터를 사용할 수 있습니다。	首頁會顯示進行中的開封項目；可從列表選單排序與篩選。	El inicio muestra tus artículos abiertos activos. Ordena y filtra desde el menú de la lista.	L’accueil affiche vos articles ouverts en cours. Triez et filtrez depuis le menu de la liste.
settings_notifications_body	Notifications help you remember your own check estimate.	通知は、自分で決めたチェック目安を思い出す手助けです。	알림은 본인이 정한 확인 기준일을 떠올리게 도와줍니다。	通知可協助你想起自己設定的檢查提醒。	Las notificaciones te ayudan a recordar tu propia estimación de revisión.	Les notifications vous aident à vous souvenir de votre rappel estimé.
settings_notifications_denied_hint	Notifications are not allowed. Please allow notifications in Settings to use reminders.	通知が許可されていません。通知を使うには設定アプリから通知を許可してください。	알림이 허용되어 있지 않습니다. 리마인더를 사용하려면 설정에서 알림을 허용하세요。	尚未允許通知。若要使用提醒，請在設定中允許通知。	Las notificaciones no están permitidas. Actívalas en Ajustes para usar recordatorios.	Les notifications ne sont pas autorisées. Autorisez-les dans Réglages pour utiliser les rappels.
settings_notifications_intro	Each item has its own reminder toggle. Alerts use your check estimate and fire on that day at your default reminder time below.	各アイテムで通知をオンにできます。下の通知時間に合わせ、チェック目安の日に届きます。	각 아이템마다 알림을 켤 수 있습니다. 아래에서 선택한 시간에 맞춰 확인 기준일에 전송됩니다。	每個項目可開啟提醒；會在你設定的檢查提醒日，依下方提醒時間送出。	Cada artículo tiene su propio interruptor. Las alertas usan tu estimación y se envían ese día a la hora predeterminada de abajo.	Chaque article a son interrupteur. Les alertes suivent votre rappel estimé, à l’heure par défaut ci-dessous ce jour-là.
settings_plan_free	Free plan	無料プラン	무료 플랜	免費方案	Plan gratuito	Offre gratuite
settings_plan_premium	Premium active	Premium有効	Premium 활성화됨	Premium 已啟用	Premium activo	Premium actif
settings_premium_benefit_multiple_photos	Multiple photos per item	写真を複数枚保存	아이템당 여러 장의 사진	每個項目可加入多張照片	Varias fotos por artículo	Plusieurs photos par article
settings_premium_body	Thank you for supporting Opelog.	Opelogを応援してくれてありがとうございます。	Opelog을 응원해 주셔서 감사합니다。	感謝你支持 Opelog。	Gracias por apoyar Opelog.	Merci de soutenir Opelog.
settings_premium_pitch	Log opened items more freely.\nPremium unlocks unlimited items, no ads, themes, and multiple photos.	もっと自由に、開封日を記録。\nPremiumでアイテム無制限、広告なし、テーマ変更、複数写真が使えます。	개봉일을 더 자유롭게 기록하세요.\nPremium으로 아이템 무제한, 광고 없음, 테마, 여러 장의 사진을 사용할 수 있습니다。	更自由地記錄開封日期。\nPremium 可解鎖無限項目、無廣告、主題與多張照片。	Registra tus productos abiertos con más libertad.\nPremium desbloquea artículos ilimitados, sin anuncios, temas y varias fotos.	Enregistrez vos produits ouverts plus librement.\nPremium débloque les articles illimités, sans publicité, les thèmes et plusieurs photos.
settings_premium_thanks	Thank you for supporting Opelog.	Opelogを応援してくれてありがとうございます。	Opelog을 응원해 주셔서 감사합니다。	感謝你支持 Opelog。	Gracias por apoyar Opelog.	Merci de soutenir Opelog.
settings_privacy_body	Your data stays on this device.	データはこの端末内に保存されます。	데이터는 이 기기에만 저장됩니다。	資料只會儲存在此裝置上。	Tus datos se guardan en este dispositivo.	Vos données restent sur cet appareil.
settings_privacy_combined_body	Your data stays on this device.\nNo account required.\nOpelog does not determine product safety or expiration. Days and reminders are based on your own settings.	データはこの端末内に保存されます。\nログインは必要ありません。\nOpelogは使用期限や安全性を判定するアプリではありません。表示される日数や通知は、ユーザー自身が設定した内容に基づきます。	데이터는 이 기기에만 저장됩니다.\n로그인은 필요하지 않습니다.\nOpelog은 제품의 안전성이나 사용 기한을 판단하지 않습니다. 표시되는 날짜와 알림은 사용자가 설정한 내용을 기반으로 합니다。	資料只會儲存在此裝置上。\n不需要登入。\nOpelog 不會判斷產品安全性或有效期限。顯示的天數與提醒皆根據你自己的設定。	Tus datos se guardan en este dispositivo.\nNo se necesita cuenta.\nOpelog no determina la seguridad ni la caducidad de los productos. Los días y recordatorios se basan en tus propios ajustes.	Vos données restent sur cet appareil.\nAucun compte requis.\nOpelog ne détermine pas la sécurité ni la date d’expiration des produits. Les jours et rappels sont basés sur vos propres réglages.
settings_section_about	About	このアプリについて	앱 정보	關於	Acerca de	À propos
settings_section_data_privacy	Data & Privacy	データとプライバシー	데이터 및 개인정보	資料與隱私	Datos y privacidad	Données et confidentialité
settings_section_display	Display	表示	표시	顯示	Visualización	Affichage
settings_section_notifications	Notifications	通知	알림	通知	Notificaciones	Notifications
settings_section_premium	Premium	プレミアム	프리미엄	Premium	Premium	Premium
settings_section_privacy	Privacy	プライバシー	개인정보	隱私	Privacidad	Confidentialité
settings_section_support	Support	サポート	지원	支援	Soporte	Assistance
settings_section_theme	Theme	テーマ	테마	主題	Tema	Thème
settings_support_placeholder	Privacy Policy, Terms of Use, and support contact will appear here before App Store release.	リリース前に、プライバシーポリシー・利用規約・お問い合わせ先をここに追加してください。	스토어 출시 전에 개인정보 처리방침, 이용약관, 문의처를 여기에 추가하세요。	App Store 上架前請在此加入隱私權政策、使用條款與聯絡方式。	La política de privacidad, los términos y el contacto irán aquí antes del lanzamiento.	La politique de confidentialité, les conditions et le contact seront ajoutés avant la sortie.
settings_theme_unlock_hint	Unlock themes with Opelog Premium.	Premiumでテーマを変更できます。	Opelog Premium으로 테마를 변경할 수 있습니다。	使用 Opelog Premium 可更換主題。	Desbloquea temas con Opelog Premium.	Débloquez les thèmes avec Opelog Premium.
settings_upgrade_button	Unlock Premium	Premiumを解放	Premium 잠금 해제	解鎖 Premium	Desbloquear Premium	Débloquer Premium
status_good	Good	良好	양호	良好	Bien	Bon
status_past	Past estimate	目安超過	기준일 경과	超過提醒	Pasado el estimado	Dépassement du rappel
status_soon	Soon	そろそろ	곧	即將	Pronto	Bientôt
tab_archive	Finished Log	使い切りログ	사용 완료	用完記錄	Terminados	Terminés
tab_home	Home	ホーム	홈	首頁	Inicio	Accueil
tab_settings	Settings	設定	설정	設定	Ajustes	Réglages
tagline_about	Remember when you opened it.	開けた日を忘れない。	언제 열었는지 잊지 마세요。	不再忘記什麼時候打開的。	Recuerda cuándo lo abriste.	Souvenez-vous de la date d’ouverture.
tagline_home	Remember when you opened it.	「これ、いつ開けたっけ？」を忘れない。	언제 열었는지 잊지 마세요。	不再忘記什麼時候打開的。	Recuerda cuándo lo abriste.	Souvenez-vous de la date d’ouverture.
tagline_sub	Log it once. Remember it later.	一度記録して、あとで思い出せる。	한 번 기록해 두면 나중에 떠올릴 수 있어요。	記一次，日後好回憶。	Regístralo una vez y recuérdalo después.	Enregistrez une fois, rappelez-vous plus tard.
theme	Theme	テーマ	테마	主題	Tema	Thème
theme_classic_cream	Classic Cream	クラシッククリーム	클래식 크림	經典奶油	Crema clásica	Crème classique
theme_lavender	Lavender	ラベンダー	라벤더	薰衣草紫	Lavanda	Lavande
theme_minimal_white	Minimal White	ミニマルホワイト	미니멀 화이트	極簡白	Blanco minimalista	Blanc minimal
theme_sage_green	Sage Green	セージグリーン	세이지 그린	鼠尾草綠	Verde salvia	Vert sauge
theme_soft_pink	Soft Pink	ソフトピンク	소프트 핑크	柔粉	Rosa suave	Rose doux
theme_warm_peach	Warm Peach	ウォームピーチ	웜 피치	暖桃	Durazno cálido	Pêche chaude
themes	Themes	テーマ	테마	主題	Temas	Thèmes
used_for_days_format	Used for %d days	%d日間使用	%d일 사용	已使用 %d 天	Usado durante %d días	Utilisé pendant %d jours
used_for_one_day	Used for 1 day	1日間使用	1일 사용	已使用 1 天	Usado durante 1 día	Utilisé pendant 1 jour
notification_time_label	Notification time	通知時間	알림 시간	通知時間	Hora de notificación	Heure de notification
reminder_time_label	Reminder Time	通知時間	리마인더 시간	提醒時間	Hora del recordatorio	Heure du rappel
permission_camera_denied	Camera access is not allowed. Please allow camera access in Settings.	カメラへのアクセスが許可されていません。設定アプリからカメラへのアクセスを許可してください。	카메라 접근이 허용되어 있지 않습니다. 설정에서 카메라 접근을 허용하세요。	尚未允許相機存取。請在設定中允許相機存取。	El acceso a la cámara no está permitido. Permítelo en Ajustes.	L’accès à l’appareil photo n’est pas autorisé. Autorisez-le dans Réglages.
permission_photo_denied	Photo access is not allowed. Please allow photo access in Settings.	写真へのアクセスが許可されていません。設定アプリから写真へのアクセスを許可してください。	사진 접근이 허용되어 있지 않습니다. 설정에서 사진 접근을 허용하세요。	尚未允許照片存取。請在設定中允許照片存取。	El acceso a las fotos no está permitido. Permítelo en Ajustes.	L’accès aux photos n’est pas autorisé. Autorisez-le dans Réglages.
ads_remove_with_premium	Remove ads with Premium	Premiumで広告を非表示	Premium으로 광고 제거	使用 Premium 移除廣告	Elimina anuncios con Premium	Supprimez les publicités avec Premium
ads_hidden_for_premium	Ads are hidden for Premium users.	Premiumユーザーには広告が表示されません。	Premium 사용자에게는 광고가 표시되지 않습니다。	Premium 使用者不會看到廣告。	Los usuarios Premium no ven anuncios.	Les utilisateurs Premium ne voient pas de publicité.
settings_current_plan	Current plan	現在のプラン	현재 플랜	目前方案	Plan actual	Offre actuelle
settings_privacy_policy	Privacy Policy	プライバシーポリシー	개인정보 처리방침	隱私權政策	Política de privacidad	Politique de confidentialité
settings_terms_of_use	Terms of Use	利用規約	이용약관	使用條款	Términos de uso	Conditions d’utilisation
settings_contact_support	Contact support	お問い合わせ	문의하기	聯絡支援	Contactar soporte	Contacter l’assistance
settings_version_label	Version	バージョン	버전	版本	Versión	Version
"""


def load_embedded_rows() -> dict[str, dict[str, str]]:
    reader = csv.DictReader(io.StringIO(TSV_BULK), delimiter="\t")
    out: dict[str, dict[str, str]] = {}
    for row in reader:
        key = row["key"].strip()
        if not key:
            continue
        out[key] = {lang: (row.get(lang) or "").replace("\\n", "\n").strip() for lang in LANGS}
    return out


def main() -> None:
    data = json.loads(XC_PATH.read_text(encoding="utf-8"))
    by_key = load_embedded_rows()
    for part in PARTS:
        if not part.exists():
            continue
        with part.open(encoding="utf-8", newline="") as f:
            reader = csv.DictReader(f, delimiter="\t")
            for row in reader:
                key = row["key"].strip()
                if not key:
                    continue
                by_key[key] = {lang: (row.get(lang) or "").replace("\\n", "\n").strip() for lang in LANGS}

    for key, locs in by_key.items():
        entry = data["strings"].setdefault(key, {})
        entry.setdefault("localizations", {})
        for lang in LANGS:
            val = locs.get(lang, "")
            if not val:
                continue
            entry["localizations"][lang] = {"stringUnit": {"state": "translated", "value": val}}

    XC_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("merged", len(by_key), "keys into", XC_PATH)


if __name__ == "__main__":
    main()

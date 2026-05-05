import Foundation

/// User-facing copy backed by `Localizable.xcstrings`. Do not hardcode UI strings in views.
enum L10n {
    private static func tr(_ key: String.LocalizationValue) -> String {
        String(localized: key)
    }

    private static func format(_ key: String.LocalizationValue, _ n: Int) -> String {
        let format = String(localized: key)
        return String(format: format, locale: .autoupdatingCurrent, n)
    }

    // MARK: - Tabs & chrome

    static var tabHome: String { tr("tab_home") }
    static var tabArchive: String { tr("tab_archive") }
    static var tabSettings: String { tr("tab_settings") }

    static var appName: String { tr("app_name") }

    /// Home hero line (EN default; JA uses main product line).
    static var taglineHome: String { tr("tagline_home") }

    /// Short line under hero / empty state helper.
    static var taglineSub: String { tr("tagline_sub") }

    /// Settings “About” second line (EN same phrase; JA shorter per copy table).
    static var taglineAbout: String { tr("tagline_about") }

    static var accessibilityAddItem: String { tr("accessibility_add_item") }

    // MARK: - Home

    static var homeEmptyTitle: String { tr("home_empty_title") }
    static var homeEmptySubtitle: String { tr("home_empty_subtitle") }

    static var homeSearchPlaceholder: String { tr("home_search_placeholder") }
    static var homeSortSection: String { tr("home_sort_section") }
    static var homeSortRecentCreated: String { tr("home_sort_recent_created") }
    static var homeSortCheckSoonest: String { tr("home_sort_check_soonest") }
    static var homeSortOpenedNewest: String { tr("home_sort_opened_newest") }
    static var homeSortOpenedOldest: String { tr("home_sort_opened_oldest") }
    static var homeFilterCategorySection: String { tr("home_filter_category_section") }
    static var homeFilterCategoryAll: String { tr("home_filter_category_all") }
    static var homeFilterStatusSection: String { tr("home_filter_status_section") }
    static var homeFilterStatusAll: String { tr("home_filter_status_all") }
    static var actionEditItem: String { tr("action_edit_item") }

    // MARK: - Archive / finished log

    static var finishedLogNavigationTitle: String { tr("finished_log_title") }

    static var archiveEmptyTitle: String { tr("archive_empty_title") }
    static var archiveEmptySubtitle: String { tr("archive_empty_subtitle") }
    static var archiveFilteredEmptyHint: String { tr("archive_filtered_empty_hint") }
    static var finishedLogEmptyTitle: String { tr("finished_log_empty_title") }
    static var finishedLogEmptySubtitle: String { tr("finished_log_empty_subtitle") }
    static var memoLabel: String { tr("memo_label") }

    static func memoWithLabel(memo: String) -> String {
        let format = String(localized: "memo_with_label_format")
        return String(format: format, locale: .autoupdatingCurrent, memoLabel, memo)
    }

    static func archiveUsedDays(_ days: Int) -> String {
        format("archive_used_days_format", days)
    }

    static func usedForDays(_ days: Int) -> String {
        if days == 1 { return tr("used_for_one_day") }
        return format("used_for_days_format", days)
    }

    static func finishedSummaryCount(_ count: Int) -> String {
        format("finished_summary_count_format", count)
    }

    static func finishedSummaryAverage(_ days: Int) -> String {
        format("finished_summary_average_format", days)
    }

    static func finishedSummaryLongest(_ days: Int) -> String {
        format("finished_summary_longest_format", days)
    }

    static func archiveOpenedLine(date: String) -> String {
        let format = String(localized: "archive_opened_line")
        return String(format: format, locale: .autoupdatingCurrent, date)
    }

    static func archiveFinishedLine(date: String) -> String {
        let format = String(localized: "archive_finished_line")
        return String(format: format, locale: .autoupdatingCurrent, date)
    }

    static func finishedPeriod(opened: String, finished: String) -> String {
        let format = String(localized: "finished_period_format")
        return String(format: format, locale: .autoupdatingCurrent, opened, finished)
    }

    // MARK: - Add item

    static var actionAddItem: String { tr("action_add_item") }
    static var personalNotesSection: String { tr("personal_notes_section") }
    static var afterUseSection: String { tr("after_use_section") }

    static var actionSave: String { tr("action_save") }
    static var saveFailedTitle: String { tr("save_failed_title") }
    static var saveFailedMessage: String { tr("save_failed_message") }
    static var actionCancel: String { tr("action_cancel") }

    static var fieldItemName: String { tr("field_item_name") }
    static var fieldCategory: String { tr("field_category") }
    static var fieldOpenedDate: String { tr("field_opened_date") }
    static var fieldUseWithin: String { tr("field_use_within") }
    static var fieldNotification: String { tr("field_notification") }
    static var fieldMemo: String { tr("field_memo") }
    static var fieldOptionalNotes: String { tr("field_optional_notes") }
    static var fieldDays: String { tr("field_days") }

    static var fieldPhoto: String { tr("field_photo") }
    static var footerPhotoLocal: String { tr("footer_photo_local") }
    static var actionAddPhoto: String { tr("action_add_photo") }
    static var addMorePhotos: String { tr("add_more_photos") }
    static var addMorePhotosWithPremium: String { tr("add_more_photos_with_premium") }
    static var multiplePhotoLimitTitle: String { tr("multiple_photo_limit_title") }
    static var multiplePhotoPremiumMaxMessage: String { tr("multiple_photo_premium_max_message") }
    static var actionTakePhoto: String { tr("action_take_photo") }
    static var actionChooseFromLibrary: String { tr("action_choose_from_library") }
    static var actionClearPhoto: String { tr("action_clear_photo") }

    static var footerUseWithinExplanation: String { tr("footer_use_within_explanation") }
    /// Explains when reminders fire, using the user’s default reminder time from Settings.
    static var footerNotificationsMvp: String {
        let time = ReminderTimeSettings.formattedTimeString()
        let format = String(localized: "footer_notifications_mvp_format")
        return String(format: format, locale: .autoupdatingCurrent, time)
    }
    static var footerNotificationsPermissionHint: String { tr("footer_notifications_permission_hint") }

    // MARK: - Local notifications

    static var notifReminderTitle: String { tr("notif_reminder_title") }

    static func notifReminderBody(itemName: String, daysOpened: Int) -> String {
        let format = String(localized: "notif_reminder_body_format")
        return String(format: format, locale: .autoupdatingCurrent, itemName, daysOpened as CVarArg)
    }

    static var dayPreset30: String { tr("day_preset_30") }
    static var dayPreset60: String { tr("day_preset_60") }
    static var dayPreset90: String { tr("day_preset_90") }
    static var dayPreset180: String { tr("day_preset_180") }
    static var dayPreset365: String { tr("day_preset_365") }
    static var dayPresetCustom: String { tr("day_preset_custom") }

    // MARK: - Item detail

    static var actionMarkFinished: String { tr("action_mark_finished") }
    static var actionDeleteItem: String { tr("action_delete_item") }

    static var alertMarkFinishedTitle: String { tr("alert_mark_finished_title") }
    static var alertMarkFinishedMessage: String { tr("alert_mark_finished_message") }

    static var detailRowCategory: String { tr("detail_row_category") }
    static var detailRowOpenedDate: String { tr("detail_row_opened_date") }
    static var detailRowTargetDate: String { tr("detail_row_target_date") }
    static var detailRowDaysSinceOpened: String { tr("detail_row_days_since_opened") }
    static var detailRowRemainingEstimate: String { tr("detail_row_remaining_estimate") }
    static var detailRowFinishedDate: String { tr("detail_row_finished_date") }
    static var detailRowUsageDays: String { tr("detail_row_usage_days") }
    static var detailRowCheckEstimate: String { tr("detail_row_check_estimate") }
    static var detailRowNotifications: String { tr("detail_row_notifications") }
    static var finishedStatus: String { tr("finished_status") }

    static var detailNotificationOn: String { tr("detail_notification_on") }
    static var detailNotificationOff: String { tr("detail_notification_off") }

    static var detailMemoHeader: String { tr("detail_memo_header") }
    static var howWasThisItem: String { tr("how_was_this_item") }
    static var detailRepurchaseStatus: String { tr("detail_repurchase_status") }
    static var detailRepurchaseNote: String { tr("detail_repurchase_note") }
    static var detailFavoriteToggle: String { tr("detail_favorite_toggle") }
    static var actionMarkFavorite: String { tr("action_mark_favorite") }
    static var actionRemoveFavorite: String { tr("action_remove_favorite") }

    static var detailHintPastEstimate: String { tr("detail_hint_past_estimate") }
    static var detailHintReplaceSoon: String { tr("detail_hint_replace_soon") }

    static var alertDeleteTitle: String { tr("alert_delete_title") }
    static var alertDeleteMessage: String { tr("alert_delete_message") }
    static var actionDelete: String { tr("action_delete") }

    // MARK: - Photo viewer

    static var photoViewerClose: String { tr("photo_viewer_close") }
    static var photoViewerTitle: String { tr("photo_viewer_title") }
    static var photoLoadFailed: String { tr("photo_load_failed") }

    static func photoPage(current: Int, total: Int) -> String {
        let format = String(localized: "photo_page_format")
        return String(format: format, locale: .autoupdatingCurrent, current as CVarArg, total as CVarArg)
    }

    // MARK: - Settings

    static var settingsSectionNotifications: String { tr("settings_section_notifications") }
    static var settingsSectionPremium: String { tr("settings_section_premium") }
    static var settingsSectionTheme: String { tr("settings_section_theme") }
    static var settingsSectionDisplay: String { tr("settings_section_display") }
    static var settingsSectionDataPrivacy: String { tr("settings_section_data_privacy") }
    static var settingsSectionSupport: String { tr("settings_section_support") }
    static var settingsSectionAbout: String { tr("settings_section_about") }

    static var settingsNotificationsIntro: String { tr("settings_notifications_intro") }
    static var settingsNotificationsDeniedHint: String { tr("settings_notifications_denied_hint") }
    static var openAppSettingsButton: String { tr("open_app_settings") }

    static var settingsDisplayBody: String { tr("settings_display_body") }

    static var settingsPrivacyCombinedBody: String { tr("settings_privacy_combined_body") }
    static var settingsSupportPlaceholder: String { tr("settings_support_placeholder") }

    static var actionOK: String { tr("action_ok") }

    // MARK: - Premium & purchases

    static var premiumTitle: String { tr("premium_title") }
    static var premiumSubtitle: String { tr("premium_subtitle") }
    static var premiumBenefitItems: String { tr("premium_benefit_items") }
    static var premiumBenefitNoAds: String { tr("premium_benefit_no_ads") }
    static var premiumBenefitArchive: String { tr("premium_benefit_archive") }
    static var premiumBenefitTheme: String { tr("premium_benefit_theme") }
    static var premiumBenefitMultiplePhotos: String { tr("premium_benefit_multiple_photos") }
    static var premiumBenefitMultiplePhotosDetail: String { tr("premium_benefit_multiple_photos_detail") }
    static var premiumBenefitFuture: String { tr("premium_benefit_future") }
    static var premiumUnlockButton: String { tr("premium_unlock_button") }
    static var premiumRestoreButton: String { tr("premium_restore_button") }
    static var premiumOnetimeNote: String { tr("premium_onetime_note") }
    static var premiumClose: String { tr("premium_close") }
    static var premiumPurchaseFailed: String { tr("premium_purchase_failed") }
    static var premiumRestoreSuccess: String { tr("premium_restore_success") }
    static var premiumAlreadyPremium: String { tr("premium_already_premium") }
    static var premiumLimitLine1: String { tr("premium_limit_line1") }
    static var premiumLimitLine2: String { tr("premium_limit_line2") }
    static var premiumPending: String { tr("premium_pending") }
    static var premiumRestoreEmpty: String { tr("premium_restore_empty") }
    static var premiumStoreUnavailable: String { tr("premium_store_unavailable") }

    static var settingsPlanFree: String { tr("settings_plan_free") }
    static var settingsPlanPremium: String { tr("settings_plan_premium") }
    static var settingsUpgradeButton: String { tr("settings_upgrade_button") }
    static var settingsPremiumPitch: String { tr("settings_premium_pitch") }
    static var settingsPremiumThanks: String { tr("settings_premium_thanks") }
    static var settingsPremiumBenefitMultiplePhotos: String { tr("settings_premium_benefit_multiple_photos") }
    static var settingsThemeUnlockHint: String { tr("settings_theme_unlock_hint") }

    static var theme: String { tr("theme") }
    static var themes: String { tr("themes") }
    static var changeTheme: String { tr("change_theme") }
    static var currentTheme: String { tr("current_theme") }
    static var premiumTheme: String { tr("premium_theme") }
    static var themeClassicCream: String { tr("theme_classic_cream") }
    static var themeSoftPink: String { tr("theme_soft_pink") }
    static var themeSageGreen: String { tr("theme_sage_green") }
    static var themeLavender: String { tr("theme_lavender") }
    static var themeMinimalWhite: String { tr("theme_minimal_white") }
    static var themeWarmPeach: String { tr("theme_warm_peach") }

    static var repurchaseFilterAll: String { tr("repurchase_filter_all") }
    static var repurchaseFilterFavorites: String { tr("repurchase_filter_favorites") }
    static var repurchaseFilterBuyAgain: String { tr("repurchase_filter_buy_again") }
    static var repurchaseFilterDoNotBuyAgain: String { tr("repurchase_filter_do_not_buy_again") }
    static var favoriteBadge: String { tr("favorite_badge") }

    static func repurchaseStatus(_ status: RepurchaseStatus) -> String {
        switch status {
        case .undecided: return tr("repurchase_not_sure")
        case .buyAgain: return tr("repurchase_buy_again")
        case .doNotBuyAgain: return tr("repurchase_do_not_buy_again")
        }
    }

    /// Short version label for About section.
    static func appVersionShort(version: String) -> String {
        let format = String(localized: "app_version_short_format")
        return String(format: format, locale: .autoupdatingCurrent, version)
    }

    static func appVersionDetail(version: String, build: String) -> String {
        let format = String(localized: "app_version_detail_format")
        return String(format: format, locale: .autoupdatingCurrent, version, build)
    }

    // MARK: - Status & relative dates

    static func status(_ status: ItemStatus) -> String {
        switch status {
        case .good: return tr("status_good")
        case .soon: return tr("status_soon")
        case .expired: return tr("status_past")
        }
    }

    static func openedDaysText(daysSinceOpened: Int) -> String {
        switch daysSinceOpened {
        case 0: return tr("opened_today")
        case 1: return tr("opened_one_day_ago")
        default: return format("opened_n_days_ago", daysSinceOpened)
        }
    }

    static func remainingCheckText(remainingDays: Int) -> String {
        if remainingDays > 1 {
            return format("check_in_n_days", remainingDays)
        }
        if remainingDays == 1 {
            return tr("check_tomorrow")
        }
        if remainingDays == 0 {
            return tr("check_today")
        }
        let past = abs(remainingDays)
        if past == 1 {
            return tr("past_estimate_one_day")
        }
        return format("past_estimate_n_days", past)
    }

    // MARK: - Categories (storage key → localized)

    static func category(storedKey: String) -> String {
        let key = ItemCategory.normalizedStorageKey(storedKey)
        switch key {
        case "Skincare": return tr("category_skincare")
        case "Makeup": return tr("category_makeup")
        case "Haircare": return tr("category_haircare")
        case "Fragrance": return tr("category_fragrance")
        case "Contact Lens": return tr("category_contact_lens")
        case "Eye Drops": return tr("category_eye_drops")
        case "Food": return tr("category_food")
        case "Pet Food": return tr("category_pet_food")
        case "Filters": return tr("category_filters")
        case "Toothbrush": return tr("category_toothbrush")
        case "Razor": return tr("category_razor")
        case "Medicine": return tr("category_medicine")
        case "Supplements": return tr("category_supplements")
        case "Daily Items": return tr("category_daily_items")
        case "Other": return tr("category_other")
        default: return storedKey
        }
    }

    static var notificationTimeLabel: String { tr("notification_time_label") }
    static var reminderTimeLabel: String { tr("reminder_time_label") }
    static var settingsReminderTimeHint: String { tr("settings_reminder_time_hint") }
    static var permissionCameraDenied: String { tr("permission_camera_denied") }
    static var permissionPhotoDenied: String { tr("permission_photo_denied") }
    static var adsRemoveWithPremium: String { tr("ads_remove_with_premium") }
    static var adsHiddenForPremium: String { tr("ads_hidden_for_premium") }
    static var settingsCurrentPlan: String { tr("settings_current_plan") }
    static var settingsPrivacyPolicy: String { tr("settings_privacy_policy") }
    static var settingsTermsOfUse: String { tr("settings_terms_of_use") }
    static var settingsContactSupport: String { tr("settings_contact_support") }
    static var settingsVersionLabel: String { tr("settings_version_label") }
}

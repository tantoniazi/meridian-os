#include "W10MSettingsModel.h"
#include <QSettings>
#include <QColor>
#include <QGuiApplication>
#include <QDebug>

W10MSettingsModel::W10MSettingsModel(QObject *parent)
    : QObject(parent)
    , m_settings(std::make_unique<QSettings>("MeridianOS", "W10M"))
{
}

W10MSettingsModel::~W10MSettingsModel() = default;

bool W10MSettingsModel::loadSettings()
{
    loadFromSettings();
    applyTheme();
    qInfo() << "Settings loaded";
    return true;
}

void W10MSettingsModel::saveSettings()
{
    saveToSettings();
    qInfo() << "Settings saved";
}

void W10MSettingsModel::resetToDefaults()
{
    m_theme = "dark";
    m_accentColor = "#0078d7";
    m_darkMode = true;
    m_highContrast = false;
    m_reducedMotion = false;
    m_fontSize = 16;
    m_language = "en_US";
    m_vibrationEnabled = true;
    m_hapticFeedback = true;
    m_animationDuration = 200;
    m_language = "en_US";
    m_autoRotate = true;
    m_screenTimeout = 60;
    m_powerProfile = "balanced";
    m_transparentTiles = true;
    m_showMoreTiles = false;
    m_lockScreenBackground = "";
    
    saveToSettings();
    applyTheme();
    
    emit themeChanged(m_theme);
    emit accentColorChanged(m_accentColor);
    emit darkModeChanged(m_darkMode);
    emit highContrastChanged(m_highContrast);
    emit reducedMotionChanged(m_reducedMotion);
    emit fontSizeChanged(m_fontSize);
    emit languageChanged(m_language);
    emit vibrationEnabledChanged(m_vibrationEnabled);
    emit hapticFeedbackChanged(m_hapticFeedback);
    emit animationDurationChanged(m_animationDuration);
    emit autoRotateChanged(m_autoRotate);
    emit screenTimeoutChanged(m_screenTimeout);
    emit powerProfileChanged(m_powerProfile);
}

void W10MSettingsModel::setTheme(const QString &theme)
{
    if (m_theme != theme) {
        m_theme = theme;
        applyTheme();
        saveToSettings();
        emit themeChanged(theme);
    }
}

void W10MSettingsModel::setAccentColor(const QString &color)
{
    if (m_accentColor != color) {
        m_accentColor = color;
        saveToSettings();
        emit accentColorChanged(color);
    }
}

void W10MSettingsModel::setDarkMode(bool enabled)
{
    if (m_darkMode != enabled) {
        m_darkMode = enabled;
        applyTheme();
        saveToSettings();
        emit darkModeChanged(enabled);
    }
}

void W10MSettingsModel::setHighContrast(bool enabled)
{
    if (m_highContrast != enabled) {
        m_highContrast = enabled;
        saveToSettings();
        emit highContrastChanged(enabled);
    }
}

void W10MSettingsModel::setReducedMotion(bool enabled)
{
    if (m_reducedMotion != enabled) {
        m_reducedMotion = enabled;
        saveToSettings();
        emit reducedMotionChanged(enabled);
    }
}

void W10MSettingsModel::setFontSize(int size)
{
    if (m_fontSize != size) {
        m_fontSize = qBound(8, size, 32);
        saveToSettings();
        emit fontSizeChanged(m_fontSize);
    }
}

void W10MSettingsModel::setLanguage(const QString &lang)
{
    if (m_language != lang) {
        m_language = lang;
        saveToSettings();
        emit languageChanged(lang);
    }
}

void W10MSettingsModel::setVibrationEnabled(bool enabled)
{
    if (m_vibrationEnabled != enabled) {
        m_vibrationEnabled = enabled;
        saveToSettings();
        emit vibrationEnabledChanged(enabled);
    }
}

void W10MSettingsModel::setHapticFeedback(bool enabled)
{
    if (m_hapticFeedback != enabled) {
        m_hapticFeedback = enabled;
        saveToSettings();
        emit hapticFeedbackChanged(enabled);
    }
}

void W10MSettingsModel::setAnimationDuration(int ms)
{
    if (m_animationDuration != ms) {
        m_animationDuration = qBound(0, ms, 1000);
        saveToSettings();
        emit animationDurationChanged(m_animationDuration);
    }
}

void W10MSettingsModel::setLanguage(const QString &lang)
{
    if (m_language != lang) {
        m_language = lang;
        saveToSettings();
        emit languageChanged(lang);
    }
}

void W10MSettingsModel::setAutoRotate(bool enabled)
{
    if (m_autoRotate != enabled) {
        m_autoRotate = enabled;
        saveToSettings();
        emit autoRotateChanged(enabled);
    }
}

void W10MSettingsModel::setScreenTimeout(int seconds)
{
    if (m_screenTimeout != seconds) {
        m_screenTimeout = qBound(15, seconds, 3600);
        saveToSettings();
        emit screenTimeoutChanged(m_screenTimeout);
    }
}

void W10MSettingsModel::setPowerProfile(const QString &profile)
{
    if (m_powerProfile != profile) {
        m_powerProfile = profile;
        saveToSettings();
        emit powerProfileChanged(profile);
    }
}

void W10MSettingsModel::setTransparentTiles(bool enabled)
{
    if (m_transparentTiles != enabled) {
        m_transparentTiles = enabled;
        saveToSettings();
        emit transparentTilesChanged(enabled);
    }
}

void W10MSettingsModel::setShowMoreTiles(bool enabled)
{
    if (m_showMoreTiles != enabled) {
        m_showMoreTiles = enabled;
        saveToSettings();
        emit showMoreTilesChanged(enabled);
    }
}

void W10MSettingsModel::setLockScreenBackground(const QString &path)
{
    if (m_lockScreenBackground != path) {
        m_lockScreenBackground = path;
        saveToSettings();
        emit lockScreenBackgroundChanged(path);
    }
}

bool W10MSettingsModel::loadSettings()
{
    loadFromSettings();
    applyTheme();
    qInfo() << "Settings loaded";
    return true;
}

void W10MSettingsModel::saveSettings()
{
    saveToSettings();
}

void W10MSettingsModel::applyTheme()
{
    // Apply theme to application
    QString styleSheet;
    
    if (m_theme == "dark") {
        qApp->setStyleSheet(
            "background-color: #1a1a1a; "
            "color: #ffffff; "
            "selection-background-color: #0078d7; "
            "selection-color: #ffffff;"
        );
    } else if (m_theme == "light") {
        qApp->setStyleSheet(
            "background-color: #f5f5f5; "
            "color: #1c1b1f; "
            "selection-background-color: #0078d7; "
            "selection-color: #ffffff;"
        );
    } else if (m_theme == "high-contrast") {
        qApp->setStyleSheet(
            "background-color: #000000; "
            "color: #ffffff; "
            "selection-background-color: #ffff00; "
            "selection-color: #000000;"
        );
    }
    
    // Apply accent color to palette
    QPalette palette = qApp->palette();
    QColor accent(m_accentColor);
    palette.setColor(QPalette::Highlight, accent);
    palette.setColor(QPalette::HighlightedText, m_darkMode ? Qt::white : Qt::black);
    qApp->setPalette(palette);
    
    // Apply font size
    QFont font = qApp->font();
    font.setPointSize(m_fontSize);
    qApp->setFont(font);
}

void W10MSettingsModel::loadFromSettings()
{
    m_theme = m_settings->value("theme", "dark").toString();
    m_accentColor = m_settings->value("accentColor", "#0078d7").toString();
    m_darkMode = m_settings->value("darkMode", true).toBool();
    m_highContrast = m_settings->value("highContrast", false).toBool();
    m_reducedMotion = m_settings->value("reducedMotion", false).toBool();
    m_fontSize = m_settings->value("fontSize", 16).toInt();
    m_language = m_settings->value("language", "en_US").toString();
    m_vibrationEnabled = m_settings->value("vibrationEnabled", true).toBool();
    m_hapticFeedback = m_settings->value("hapticFeedback", true).toBool();
    m_animationDuration = m_settings->value("animationDuration", 200).toInt();
    m_language = m_settings->value("language", "en_US").toString();
    m_autoRotate = m_settings->value("autoRotate", true).toBool();
    m_screenTimeout = m_settings->value("screenTimeout", 60).toInt();
    m_powerProfile = m_settings->value("powerProfile", "balanced").toString();
    m_transparentTiles = m_settings->value("transparentTiles", true).toBool();
    m_showMoreTiles = m_settings->value("showMoreTiles", false).toBool();
    m_lockScreenBackground = m_settings->value("lockScreenBackground", "").toString();
}

void W10MSettingsModel::saveToSettings()
{
    m_settings->setValue("theme", m_theme);
    m_settings->setValue("accentColor", m_accentColor);
    m_settings->setValue("darkMode", m_darkMode);
    m_settings->setValue("highContrast", m_highContrast);
    m_settings->setValue("reducedMotion", m_reducedMotion);
    m_settings->setValue("fontSize", m_fontSize);
    m_settings->setValue("language", m_language);
    m_settings->setValue("vibrationEnabled", m_vibrationEnabled);
    m_settings->setValue("hapticFeedback", m_hapticFeedback);
    m_settings->setValue("animationDuration", m_animationDuration);
    m_settings->setValue("autoRotate", m_autoRotate);
    m_settings->setValue("screenTimeout", m_screenTimeout);
    m_settings->setValue("powerProfile", m_powerProfile);
    m_settings->setValue("transparentTiles", m_transparentTiles);
    m_settings->setValue("showMoreTiles", m_showMoreTiles);
    m_settings->setValue("lockScreenBackground", m_lockScreenBackground);
}
#include "SettingsModel.h"
#include <QSettings>
#include <QColor>
#include <QGuiApplication>
#include <QDebug>

SettingsModel::SettingsModel(QObject *parent)
    : QObject(parent)
    , m_settings(std::make_unique<QSettings>("MeridianOS", "Home"))
{
}

SettingsModel::~SettingsModel() = default;

bool SettingsModel::loadSettings()
{
    loadFromSettings();
    applyTheme();
    qInfo() << "Settings loaded";
    return true;
}

void SettingsModel::saveSettings()
{
    saveToSettings();
    qInfo() << "Settings saved";
}

void SettingsModel::resetToDefaults()
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
    m_autoRotate = true;
    m_screenTimeout = 60;
    m_powerProfile = "balanced";
    
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

void SettingsModel::setTheme(const QString &theme)
{
    if (m_theme != theme) {
        m_theme = theme;
        applyTheme();
        saveToSettings();
        emit themeChanged(theme);
    }
}

void SettingsModel::setAccentColor(const QString &color)
{
    if (m_accentColor != color) {
        m_accentColor = color;
        saveToSettings();
        emit accentColorChanged(color);
    }
}

void SettingsModel::setDarkMode(bool enabled)
{
    if (m_darkMode != enabled) {
        m_darkMode = enabled;
        applyTheme();
        saveToSettings();
        emit darkModeChanged(enabled);
    }
}

void SettingsModel::setHighContrast(bool enabled)
{
    if (m_highContrast != enabled) {
        m_highContrast = enabled;
        saveToSettings();
        emit highContrastChanged(enabled);
    }
}

void SettingsModel::setReducedMotion(bool enabled)
{
    if (m_reducedMotion != enabled) {
        m_reducedMotion = enabled;
        saveToSettings();
        emit reducedMotionChanged(enabled);
    }
}

void SettingsModel::setFontSize(int size)
{
    if (m_fontSize != size) {
        m_fontSize = qBound(8, size, 32);
        saveToSettings();
        emit fontSizeChanged(m_fontSize);
    }
}

void SettingsModel::setLanguage(const QString &lang)
{
    if (m_language != lang) {
        m_language = lang;
        saveToSettings();
        emit languageChanged(lang);
    }
}

void SettingsModel::setVibrationEnabled(bool enabled)
{
    if (m_vibrationEnabled != enabled) {
        m_vibrationEnabled = enabled;
        saveToSettings();
        emit vibrationEnabledChanged(enabled);
    }
}

void SettingsModel::setHapticFeedback(bool enabled)
{
    if (m_hapticFeedback != enabled) {
        m_hapticFeedback = enabled;
        saveToSettings();
        emit hapticFeedbackChanged(enabled);
    }
}

void SettingsModel::setAnimationDuration(int ms)
{
    if (m_animationDuration != ms) {
        m_animationDuration = qBound(0, ms, 1000);
        saveToSettings();
        emit animationDurationChanged(m_animationDuration);
    }
}

void SettingsModel::setAutoRotate(bool enabled)
{
    if (m_autoRotate != enabled) {
        m_autoRotate = enabled;
        saveToSettings();
        emit autoRotateChanged(enabled);
    }
}

void SettingsModel::setScreenTimeout(int seconds)
{
    if (m_screenTimeout != seconds) {
        m_screenTimeout = qBound(15, seconds, 3600);
        saveToSettings();
        emit screenTimeoutChanged(m_screenTimeout);
    }
}

void SettingsModel::setPowerProfile(const QString &profile)
{
    if (m_powerProfile != profile) {
        m_powerProfile = profile;
        saveToSettings();
        emit powerProfileChanged(profile);
    }
}

bool SettingsModel::loadSettings()
{
    loadFromSettings();
    applyTheme();
    return true;
}

void SettingsModel::saveSettings()
{
    saveToSettings();
}

void SettingsModel::applyTheme()
{
    // Apply theme to application
    QString styleSheet;
    
    if (m_theme == "dark") {
        styleSheet = QString(
            "background-color: #%1; "
            "color: #%2; "
            "selection-background-color: #%3; "
            "selection-color: #%4;"
        ).arg(m_darkMode ? "1a1a1a" : "f5f5f5")
         .arg(m_darkMode ? "ffffff" : "1c1b1f")
         .arg(m_accentColor.mid(1))
         .arg(m_darkMode ? "ffffff" : "000000");
    } else if (m_theme == "light") {
        styleSheet = QString(
            "background-color: #f5f5f5; "
            "color: #1c1b1f; "
            "selection-background-color: #%1; "
            "selection-color: #000000;"
        ).arg(m_accentColor.mid(1));
    } else if (m_theme == "high-contrast") {
        styleSheet = QString(
            "background-color: #%1; "
            "color: #%2; "
            "selection-background-color: #%3; "
            "selection-color: #%4;"
        ).arg(m_darkMode ? "000000" : "ffffff")
         .arg(m_darkMode ? "ffffff" : "000000")
         .arg("ffff00")
         .arg(m_darkMode ? "000000" : "ffffff");
    }
    
    qApp->setStyleSheet(styleSheet);
    
    // Apply accent color to palette
    QPalette palette = qApp->palette();
    QColor accent(m_accentColor);
    palette.setColor(QPalette::Highlight, accent);
    palette.setColor(QPalette::HighlightedText, m_darkMode ? Qt::white : Qt::black);
    qApp->setPalette(palette);
}

void SettingsModel::loadFromSettings()
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
    m_autoRotate = m_settings->value("autoRotate", true).toBool();
    m_screenTimeout = m_settings->value("screenTimeout", 60).toInt();
    m_powerProfile = m_settings->value("powerProfile", "balanced").toString();
}

void SettingsModel::saveToSettings()
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
}
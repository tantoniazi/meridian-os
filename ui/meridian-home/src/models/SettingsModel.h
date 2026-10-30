#pragma once

#include <QObject>
#include <QSettings>
#include <QColor>
#include <QFont>

class SettingsModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(QString accentColor READ accentColor WRITE setAccentColor NOTIFY accentColorChanged)
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged)
    Q_PROPERTY(bool highContrast READ highContrast WRITE setHighContrast NOTIFY highContrastChanged)
    Q_PROPERTY(bool reducedMotion READ reducedMotion WRITE setReducedMotion NOTIFY reducedMotionChanged)
    Q_PROPERTY(int fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(bool vibrationEnabled READ vibrationEnabled WRITE setVibrationEnabled NOTIFY vibrationEnabledChanged)
    Q_PROPERTY(bool hapticFeedback READ hapticFeedback WRITE setHapticFeedback NOTIFY hapticFeedbackChanged)
    Q_PROPERTY(int animationDuration READ animationDuration WRITE setAnimationDuration NOTIFY animationDurationChanged)
    Q_PROPERTY(bool autoRotate READ autoRotate WRITE setAutoRotate NOTIFY autoRotateChanged)
    Q_PROPERTY(int screenTimeout READ screenTimeout WRITE setScreenTimeout NOTIFY screenTimeoutChanged)
    Q_PROPERTY(QString powerProfile READ powerProfile WRITE setPowerProfile NOTIFY powerProfileChanged)

public:
    explicit SettingsModel(QObject *parent = nullptr);
    ~SettingsModel() override;

    QString theme() const { return m_theme; }
    QString accentColor() const { return m_accentColor; }
    bool darkMode() const { return m_darkMode; }
    bool highContrast() const { return m_highContrast; }
    bool reducedMotion() const { return m_reducedMotion; }
    int fontSize() const { return m_fontSize; }
    QString language() const { return m_language; }
    bool vibrationEnabled() const { return m_vibrationEnabled; }
    bool hapticFeedback() const { return m_hapticFeedback; }
    int animationDuration() const { return m_animationDuration; }
    QString language() const { return m_language; }
    bool autoRotate() const { return m_autoRotate; }
    int screenTimeout() const { return m_screenTimeout; }
    QString powerProfile() const { return m_powerProfile; }

    void setTheme(const QString &theme);
    void setAccentColor(const QString &color);
    void setDarkMode(bool enabled);
    void setHighContrast(bool enabled);
    void setReducedMotion(bool enabled);
    void setFontSize(int size);
    void setLanguage(const QString &lang);
    void setVibrationEnabled(bool enabled);
    void setHapticFeedback(bool enabled);
    void setAnimationDuration(int ms);
    void setAutoRotate(bool enabled);
    void setScreenTimeout(int seconds);
    void setPowerProfile(const QString &profile);

    bool loadSettings();
    void saveSettings();
    void resetToDefaults();

signals:
    void themeChanged(const QString &theme);
    void accentColorChanged(const QString &color);
    void darkModeChanged(bool enabled);
    void highContrastChanged(bool enabled);
    void reducedMotionChanged(bool enabled);
    void fontSizeChanged(int size);
    void languageChanged(const QString &lang);
    void vibrationEnabledChanged(bool enabled);
    void hapticFeedbackChanged(bool enabled);
    void animationDurationChanged(int ms);
    void autoRotateChanged(bool enabled);
    void screenTimeoutChanged(int seconds);
    void powerProfileChanged(const QString &profile);

private:
    std::unique_ptr<QSettings> m_settings;

    QString m_theme = "dark";
    QString m_accentColor = "#0078d7";
    bool m_darkMode = true;
    bool m_highContrast = false;
    bool m_reducedMotion = false;
    int m_fontSize = 16;
    QString m_language = "en_US";
    bool m_vibrationEnabled = true;
    bool m_hapticFeedback = true;
    int m_animationDuration = 200;
    bool m_autoRotate = true;
    int m_screenTimeout = 60;
    QString m_powerProfile = "balanced";

    void applyTheme();
    void loadFromSettings();
    void saveToSettings();
};
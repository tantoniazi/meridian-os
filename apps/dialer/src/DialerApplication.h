#pragma once

#include <QObject>
#include <memory>

class CallModel;
class ContactModel;
class USSDModel;
class CallController;
class ContactController;
class USSDController;

class DialerApplication : public QObject
{
    Q_OBJECT
    Q_PROPERTY(CallModel* callModel READ callModel CONSTANT)
    Q_PROPERTY(ContactModel* contactModel READ contactModel CONSTANT)
    Q_PROPERTY(USSDModel* ussdModel READ ussdModel CONSTANT)
    Q_PROPERTY(CallController* callController READ callController CONSTANT)
    Q_PROPERTY(ContactController* contactController READ contactController CONSTANT)
    Q_PROPERTY(USSDController* ussdController READ ussdController CONSTANT)

public:
    explicit DialerApplication(QObject *parent = nullptr);
    ~DialerApplication() override;

    bool initialize();

    CallModel* callModel() const { return m_callModel.get(); }
    ContactModel* contactModel() const { return m_contactModel.get(); }
    USSDModel* ussdModel() const { return m_ussdModel.get(); }
    CallController* callController() const { return m_callController.get(); }
    ContactController* contactController() const { return m_contactController.get(); }
    USSDController* ussdController() const { return m_ussdController.get(); }

private:
    std::unique_ptr<CallModel> m_callModel;
    std::unique_ptr<ContactModel> m_contactModel;
    std::unique_ptr<USSDModel> m_ussdModel;
    std::unique_ptr<CallController> m_callController;
    std::unique_ptr<ContactController> m_contactController;
    std::unique_ptr<USSDController> m_ussdController;
};
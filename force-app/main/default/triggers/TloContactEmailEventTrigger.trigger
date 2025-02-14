trigger TloContactEmailEventTrigger on Tlo_Contact_Email_Event__e (after insert) {
    TloContactEmailEventHandler handler = new TloContactEmailEventHandler();
    handler.run();
}
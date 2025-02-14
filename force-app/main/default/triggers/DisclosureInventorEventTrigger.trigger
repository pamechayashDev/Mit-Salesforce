trigger DisclosureInventorEventTrigger on DisclosureInventor_Event__e (after insert) {
    DisclosureInventorEventHandler handler = new DisclosureInventorEventHandler();
    handler.run();
}
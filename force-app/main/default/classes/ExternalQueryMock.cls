public with sharing class ExternalQueryMock {
    // Static instance of the singleton class
    private static ExternalQueryMock instance;

    // Cache to store lists of lists of sObjects by their type
    private Map<String, List<List<SObject>>> cache;

    // Private constructor to prevent instantiation
    private ExternalQueryMock() {
        this.cache = new Map<String, List<List<SObject>>>();
    }

    // Public method to get the singleton instance
    public static ExternalQueryMock getInstance() {
        if (instance == null) {
            instance = new ExternalQueryMock();
        }
        return instance;
    }

    // Method to add a list of sObjects to the cache
    public void setDataStore(String sObjectType, List<SObject> dataStore) {
        if (this.cache.containsKey(sObjectType)) {
            this.cache.get(sObjectType).add(dataStore);
        } else {
            this.cache.put(sObjectType, new List<List<SObject>>{ dataStore });
        }
    }

    // Method to get the first list of sObjects for a specific sObject type, remove it from the cache, and return the list
    public List<SObject> query(String sObjectType) {
        if (
            this.cache.containsKey(sObjectType) &&
            !this.cache.get(sObjectType).isEmpty()
        ) {
            return this.cache.get(sObjectType).remove(0);
        } else {
            return new List<SObject>();
        }
    }

    // Method to clear the cache (useful for resetting state in tests)
    public void clearCache() {
        this.cache.clear();
    }
}
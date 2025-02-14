public with sharing class FilterChainStrategy implements FilterChain {

    Iterator<ScopeFilter> filters;

    public FilterChainStrategy(List<ScopeFilter> filters) {
        this.filters = filters.iterator();
    }
    
    public List<SObject> doFilter(List<SObject> scope) {
        if (filters.hasNext()) {
            ScopeFilter filter = filters.next();
            return filter.doFilter(scope, this);
        }
        return scope;
    }
}
global class GenericCSVBatch implements Database.Batchable<SObject>, Database.Stateful {
    private GenericCSVBatch.Settings batchSettings;
    private List<String> csvContent;
    private Integer rows = 0;

    // Constructor to accept the query, field names, and CSV title
    public GenericCSVBatch(GenericCSVBatch.Settings batchSettings) {
        this.batchSettings = batchSettings;

        this.csvContent = new List<String>();

        // Add CSV header
        if (this.batchSettings.csvColumnNames != null && !this.batchSettings.csvColumnNames.isEmpty()) {
            this.csvContent.add(String.join(this.batchSettings.csvColumnNames, ','));
        } else {
            this.csvContent.add(String.join(this.batchSettings.fieldNames, ','));
        }

    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.batchSettings.query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('GenericCSVBatch:start ' + scope.size());
        List<SObject> scopeFilter = scope;
        if(batchSettings.filters != null && !batchSettings.filters.isEmpty()) {
            FilterChainStrategy filterChain = new FilterChainStrategy(batchSettings.filters);
            scopeFilter = filterChain.doFilter(scope);
        }

        this.rows += scopeFilter.size();
        // Append CSV data for the current batch
        this.csvContent.add('\n' + CsvUtils.toCSV(scopeFilter, this.batchSettings.fieldNames));
    }

    global void finish(Database.BatchableContext bc) {
        // Send the CSV data to a email attachment
        String subscriber = this.batchSettings.toEmailAddress != null ? this.batchSettings.toEmailAddress : getCustomReportEmailAddress();
        Boolean emailEnabled = this.batchSettings.enableEmailDelivery != null ? this.batchSettings.enableEmailDelivery : getCustomReportEmailEnabled();
        if (!emailEnabled ) {
            CsvUtils.saveCSVFile(String.join(csvContent,''), this.batchSettings.csvTitle);
        } else {
            String htmlBody = this.batchSettings.htmlBody;

            String rows = 'Size of report ' + this.rows  + ' lines</div>';
            htmlBody = htmlBody.replace('<div="place_holder"></div>', rows);

            CsvUtils.sendCSVFile(htmlBody ,String.join(this.csvContent,''), this.batchSettings.csvTitle, subscriber);
        }

    }

    public static String getCustomReportEmailAddress() {
        return ConfigurationBuilder.getConfigurationToString(
            'CustomReportEmail'
        );
    }

    public static Boolean getCustomReportEmailEnabled() {

        String enabled = ConfigurationBuilder.getConfigurationToString(
            'CustomReportEmailEnabled'
        );
        return Boolean.valueOf(enabled);
    }


    public class Settings {
        public String query { get; set; }
        public List<String> fieldNames { get; set; }
        public List<String> csvColumnNames { get; set; }
        public String csvTitle { get; set; }
        public String toEmailAddress { get; set; }
        public Boolean enableEmailDelivery { get; set; }
        public String htmlBody { get; set; }
        public List<ScopeFilter> filters;

    }
}
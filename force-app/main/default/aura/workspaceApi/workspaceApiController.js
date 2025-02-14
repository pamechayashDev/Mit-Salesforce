({
    //https://blogs.absyz.com/2020/06/15/opening-lightning-web-component-lwc-as-subtab-in-lightning-console/
    doinit : function(component, event, helper) {
        const c__mitid =  component.get("v.pageReference").state.c__mitid;
        const c__name =  component.get("v.pageReference").state.c__name;

        var workspaceAPI = component.find("workspace");

        workspaceAPI.getFocusedTabInfo().then(function(response) {
            workspaceAPI.isSubtab({
                tabId: response.tabId
            }).then(function(response) {
                if (!response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: c__name
                    });
                    workspaceAPI.setTabIcon({ //https://www.lightningdesignsystem.com/icons/#action
                        tabId: focusedTabId,
                        icon: "standard:avatar",
                        iconAlt: c__name
                    });
                }
            });
        })
        .catch(function(error) {
            console.log(error);
        });
       
    },
    //https://sfwiseguys.wordpress.com/2020/11/15/lwc-navigation/
    openTab: function(component, event, helper) {
        
    }
})
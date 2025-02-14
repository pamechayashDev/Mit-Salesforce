// https://copyprogramming.com/howto/how-to-close-all-tabs-at-once-using-selenium-java

// https://mtr-design.com/news/salesforce-mini-how-to-open-a-subtab-in-console-from-lightning-web-component
export function invokeWorkspaceAPI(methodName, methodArgs) {

    console.log(methodName, methodArgs);
    
    return new Promise((resolve, reject) => {
        console.log(resolve, reject);
        const apiEvent = new CustomEvent("internalapievent", {
            bubbles: true,
            composed: true,
            cancelable: false,
            detail: {
                category: "workspaceAPI",
                methodName: methodName,
                methodArgs: methodArgs,
                callback: (err, response) => {
                    console.log(err, response);
                    if (err) {
                        return reject(err);
                    } else {
                        return resolve(response);
                    }
                }
            }
        });

        console.log(apiEvent);

        window.dispatchEvent(apiEvent);
    });
}

// others to have a read on
// https://unofficialsf.com/load-a-visualforce-page-with-parameters-in-lightning/
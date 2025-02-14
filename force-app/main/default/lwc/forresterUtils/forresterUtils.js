/**
 * Helper function that convert Text to Boolean
 * @param {value} String containing Yes, No or Undefined
 * @returns True or False or Undefined
 */
export function yesNoFromString (value) {
    if(value === undefined || value === null) {
        return undefined;
    }
    return value.toUpperCase().startsWith("YES", 0) ? true : value.toUpperCase().startsWith("NO", 0) ? false : undefined;
}

function jsonPropertyFromValue(value) {
    // stringify does not serialize undefined, The Forrester API use undefined and does not support null values.
    return (value === null || value === undefined) ?  undefined : value ;
   
}
/**
 * Forrester API Flags required to of Type Boolean or Undefined, This function convert Yes, No, True, False, Unknown to True, False or undefined
 * @param value, the String value containing on of ['Yes','Y','True','No','N','False','Unknown']
 * @return True, False or undefined
 * */
function booleanFromYNU (value) {
    return (value === null || value === undefined || value.toUpperCase() === 'UNKNOWN') ? undefined : ( (value.toUpperCase() === 'YES' || value.toUpperCase() === 'Y' || value.toUpperCase() === 'TRUE' ) ? true : false)
}

/**
 * Forrester This function convert True, False, Undefined to Yes, No, Unknown
 * @param value, the Boolean value, could be Undefined
 * @return True, False or Unknown
 * */
function ynuFromBoolean (value) {
    return (value === null || value === undefined ) ? 'Unknown' : ( (value) ? 'Yes' : 'No')
}

/**
 * @param value, The error message from aws that need to be user friendly. Removing unwanted key words
 * @return message with Http Error codes messages removed
 * */
function filterAWSErrorMessage (message) {
    const keyWord = [/^Bad Request:/gi, /^Error:/gi,/Internal Server Error:/gi]
    if (message === null || message === undefined ) {
        return;
    }
    if (typeof message === 'string' || message instanceof String) {
        let value = message.trim()

        keyWord.forEach(x => {
            value = value.replace(x, '').trim();
        })
        return value;
    }else {
        return message
    }
}
/**
 * @param Date value, Birth date in year
 * @return Forrester expect birth day in format of MMDD
 * */
function birthDayFromValue(value) {
    if( value == null ) {
        return undefined;
    }
    let birthDate;
    if (typeof value === 'string' || value instanceof String) {
        birthDate = Date.parse(value)
    }else {
        birthDate = value
    }

    const options = {
        month: "2-digit",
        day: "2-digit",
    };

    const dateFormatter = new Intl.DateTimeFormat("en-US", options);
    console.debug(birthDate)

    const toString = dateFormatter.format(birthDate).replace('/','');

    console.debug(toString)
    return toString;

}
/**
 * Add key value pair to array only if key and value is not undefined.
 * @param String array
 * @param String key
 * @param String value
 * @return void
 * */
function arrayPushKeyValue(array, key, value) {
    if (array === null || array === undefined || value === null || value === undefined || key === null || key === undefined  ) {
        return;
    }
    array.push(`${key}: ${value}`);
}


function errorToList(error) {

    const messages = []
    if (error.message ){
        messages.push(filterAWSErrorMessage(error.message));
    }
    if (error.body?.error ){
        messages.push(filterAWSErrorMessage(error.body?.error));
    }
    if (error.body?.message ){
        messages.push(filterAWSErrorMessage(error.body?.message));
    }
    if (error.body?.output?.errors) {
        error.body?.output?.errors.forEach(x=> {
            messages.push(filterAWSErrorMessage(x.message))
        })
    }
    if (error.body?.fieldErrors) {
        for (const [key, value] of Object.entries(error.body?.fieldErrors)) {
            if (Array.isArray(value)) {
                value.forEach(x => {
                    messages.push(filterAWSErrorMessage(x.message))
                })
            }
        }
    }

    if (messages.length === 0 && error.statusText) {
        messages.push(filterAWSErrorMessage(error.statusText));
    }

    return messages.join('\r\n');

}


export { jsonPropertyFromValue, booleanFromYNU, ynuFromBoolean, filterAWSErrorMessage, birthDayFromValue, arrayPushKeyValue, errorToList }
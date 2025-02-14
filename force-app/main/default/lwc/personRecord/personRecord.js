import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import restGet from '@salesforce/apex/AwsApiCall.restGet';

import { determineActiveStatus, getFullName, getInstitution } from 'c/utils';


export default class PersonRecord extends LightningElement {
    person = {
        affiliation: null,
        dateOfBirth: null,
        department: null,
        display_name: null,
        email: null,
        fullName: null,
        initials: null,
        kerberos: null,
        kerberos_id: null,
        krb_name: null,
        legalFirstName: null,
        legalLastName: null,
        legalMiddleName: null,
        mailto_alumniEmail: null,
        mailto_mitEmail: null,
        mailto_nonMitEmail: null,
        mitHROrganisationId: null,
        mitMoiraStatus: null,
        mitPreferredMail: null,
        mit_id: null,
        mitid: null,
        office_location: null,
        phone_number: null,
        source: null,
        title: null
    };
    digitalId = {office_location: ''};
    currentPageReference = null;
    searchError = false;
    loading = true;

    passedId = null;

    @wire(CurrentPageReference)
    async getPageReferenceParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state.c__mitid !== undefined) {
            this.passedId = await currentPageReference.state.c__mitid;
            await this.getPersonDetailsById();
        }
    }

    getMailToEmail(email) {
        return `mailto:${email}`
    }

    getPersonDetailsById = async () => {
        let data;
        this.loading = true;
        this.searchError = false;
        try {
            const apiName = 'peopleSearchApi'
            const res = await restGet({ api: apiName, resource: (`/search?query=${this.passedId}&krbStatus=any`) });

            data = JSON.parse(res);
            if (data.people) {
                this.person = data.people[0];
                this.person.dob = this.person.dobMonth && this.person.dobDay ? this.person.dobMonth + '-' + this.person.dobDay : ''
                
                //iterate over all fields in data and replace null with empty string
                for (let key in this.person) {
                    if (this.person[key] === null) {
                        this.person[key] = '⠀';
                    }
                }

                // Full Name
                this.person.fullName = getFullName(
                    this.person.legalFirstName,
                    this.person.legalMiddleName,
                    this.person.legalLastName
                )

                // Mail to email fields
                this.person.mailto_mitEmail = this.getMailToEmail(this.person.mitEmail)
                this.person.mailto_nonMitEmail = this.getMailToEmail(this.person.nonMitEmail)
                this.person.mailto_alumniEmail = this.getMailToEmail(this.person.alumniEmail)

                // Affiliation
                this.person.affiliation = [
                    (this.person.affiliate ? 'Affiliate' : null),
                    (this.person.staff ? 'Staff' : null),
                    (this.person.student ? 'Student' : null),
                    (this.person.alumni ? 'Alumni' : null),
                    (this.person.guest) ? 'Guest' : null
                ].filter(function (e) { return e }).join('/')

                // Kerb Status
                this.person.krbStatus = determineActiveStatus(this.person.moiraStatus)
                this.person.inst = getInstitution(this.person.krbStatus, this.person.institution)

                // Digital Id fields
                try {
                    const apiName = 'digitalIdApi'
                    const digitalIdRes = await restGet({ api: apiName, resource: (`/profile/${this.passedId}?allStatus=true`) })

                    this.digitalId = JSON.parse(digitalIdRes)

                    //iterate over all fields in data and replace null with empty string
                     for (let key in this.digitalId) {
                        if (this.digitalId[key] === null) {
                            this.digitalId[key] = '⠀';
                        }
                    }
                } catch (error) {
                    console.error(`%c [ERROR]`, `color: red`, error);
                }
            }
        } catch (error) {
            console.error(`%c [ERROR]`, `color: red`, error);
            this.searchError = true;
        }
        this.loading = false;
    }
}
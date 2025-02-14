import getBioTangByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getBioTangByDisclosureId"
import getLabMaterialsByBioTangId from "@salesforce/apex/DisclosureRecordFetch.getLabMaterialsByBioTangId"
import getMouseStrainByBioTangId from "@salesforce/apex/DisclosureRecordFetch.getMouseStrainByBioTangId"
import getAntibodyByBioTangId from "@salesforce/apex/DisclosureRecordFetch.getAntibodyByBioTangId"
import getCellLineByBioTangId from "@salesforce/apex/DisclosureRecordFetch.getCellLineByBioTangId"
import getPlasmidByBioTangId from "@salesforce/apex/DisclosureRecordFetch.getPlasmidByBioTangId"
import getOtherMaterialByBioTangId from "@salesforce/apex/DisclosureRecordFetch.getOtherMaterialByBioTangId"
import { jsonPropertyFromValue, booleanFromYNU } from "c/forresterUtils"
import { getDisclosureBody } from 'c/disclosureBodyRest';


const populateBioTangData = (async (disclosure, user) => {
    let bodyData = await getDisclosureBody(disclosure, user)
    console.log('🅰️ Starting populateBioTangData')
    let biotang = getBioTangByDisclosureId({disclosureId: disclosure.id}).then((result) => {
        console.log('results', result[0])
        return result[0]
    }).catch((error) => {
        console.log('Error fetching BioTang Disclosure', error)
    })


    return biotang.then((fields) => {
        console.log('Populating BioTang')
        if (fields == null || fields === undefined) {
            console.log('🔴 Error: NO BioTang exist, for Disclosure: ' + disclosure.id)
            throw new Error('NO BioTang exist, for Disclosure: ' + disclosure.id)
        }


        bodyData.disclosureBody = {
            "disclosureType": "BioTang",
            "materialsFromOtherLabsFlag": booleanFromYNU(fields.materialsFromOtherLabs__c),
            "materialsFurtherComments": jsonPropertyFromValue(fields.materialsFurtherComments__c),
            "frequencyOfRequests": jsonPropertyFromValue(fields.frequencyOfRequests__c),
            "publicationsFlag": booleanFromYNU(fields.publications__c),
            "publicationsReferences": undefined,
            "publicationsLinkToRef": jsonPropertyFromValue(fields.publicationsLinkToRef__c),
            "wasDevPartOfCollaborationFlag": booleanFromYNU(fields.wasDevAsPartOfCollaboration__c),
            "collaboratorsDetail": jsonPropertyFromValue(fields.Collaborators_Detail__c),
            "depositedAtRepositoryFlag": booleanFromYNU(fields.depositedAtRepository__c),
            "repositoryDetails": jsonPropertyFromValue(fields.repositoryDetails__c),
            "depositAndDistribution": jsonPropertyFromValue(fields.depositAndDistribution__c),
            "openDate": undefined,
            "mitPointOfContact": {
                "name": fields.MIT_Point_of_Contact_Acc__r ? jsonPropertyFromValue(fields.MIT_Point_of_Contact_Acc__r?.Name) : undefined,
                "mitid": fields.MIT_Point_of_Contact_Acc__r ? jsonPropertyFromValue(fields.MIT_Point_of_Contact_Acc__r?.MitId__pc) : undefined,
                "email": fields.MIT_Point_of_Contact_Acc__r ? jsonPropertyFromValue(fields.MIT_Point_of_Contact_Acc__r?.PersonEmail) : undefined,
            },
            "mitShipper": {
                "name": fields.MIT_Shipper_Acc__r ? jsonPropertyFromValue(fields.MIT_Shipper_Acc__r?.Name) : undefined,
                "mitid": fields.MIT_Shipper_Acc__r ? jsonPropertyFromValue(fields.MIT_Shipper_Acc__r?.MitId__pc) : undefined,
                "email": fields.MIT_Shipper_Acc__r ? jsonPropertyFromValue(fields.MIT_Shipper_Acc__r?.PersonEmail) : undefined,
            },
            "labMaterials": undefined
        }


        if (fields.MIT_Point_of_Contact_Acc__r == null) {
            bodyData.disclosureBody.mitPointOfContact = undefined;
        }
        if (fields.MIT_Shipper_Acc__r == null) {
            bodyData.disclosureBody.mitShipper = undefined;
        }

        return getLabMaterialsByBioTangId({ biotangId: fields.Id }).then((labMaterials) => {
            console.log("Lab Materials", labMaterials)
            bodyData.disclosureBody.labMaterials = []
            for (let i = 0; i < labMaterials.length; i++) {
                bodyData.disclosureBody.labMaterials.push(
                    {
                        "name": labMaterials[i] ? jsonPropertyFromValue(labMaterials[i].Name) : undefined,
                        "source": labMaterials[i] ? jsonPropertyFromValue(labMaterials[i].Source__c) : undefined,
                        "howWasMaterialObtained": labMaterials[i] ? jsonPropertyFromValue(labMaterials[i].How_Was_Material_Obtained__c) : undefined,
                        "materialObtainedOtherDesc": labMaterials[i] ? jsonPropertyFromValue(labMaterials[i].Material_Obtained_Other_Desc__c) : undefined
                    }
                )
            }


            if (fields.RecordType.DeveloperName === 'mouseStrain') {
                return getMouseStrainByBioTangId({ biotangId: fields.Id }).then((mousestrain) => {
                    console.log("Mouse Strain", mousestrain[0])
                    bodyData.disclosureBody.bioTangBody = {
                        "typeOfTP": "MouseStrain",
                        "nameOfTP": mousestrain[0] ? jsonPropertyFromValue(mousestrain[0].Name) : undefined,
                        "maintenanceAndBreeding": mousestrain[0] ? jsonPropertyFromValue(mousestrain[0].maintenanceAndBreeding__c) : undefined,
                        "mouseGenCrossOtherFlag": mousestrain[0] ? jsonPropertyFromValue(mousestrain[0].Mouse_Gen_Cross_Other__c) : undefined, //checkbox
                        "mouseStrainGenDetails": mousestrain[0] ? jsonPropertyFromValue(mousestrain[0].Mouse_Strain_Gen_Details__c) : undefined
                    }

                    return bodyData
                }).catch((error) => {
                    console.log(error)
                })
            } else if (fields.RecordType.DeveloperName === 'antibody') {
                return getAntibodyByBioTangId({ biotangId: fields.Id }).then((antibody) => {
                    console.log("Antibody", antibody[0])
                    bodyData.disclosureBody.bioTangBody = {
                        "typeOfTP": "Antibody",
                        "nameOfTP": antibody[0] ? jsonPropertyFromValue(antibody[0].Name) : undefined,
                        'antibodyValidApplications': (antibody[0] != null && antibody[0].antibodyValidApplications__c != null) ? antibody[0].antibodyValidApplications__c.replace(';', ', ') : null,
                        'antibodyValidAppOther': antibody[0] ? jsonPropertyFromValue(antibody[0].antibodyValidAppOther__c) : undefined,
                        'purificationRequiredFlag': antibody[0] ? booleanFromYNU(antibody[0].isPurificationRequired__c) : undefined
                    }

                    return bodyData
                }).catch((error) => {
                    console.log(error)
                })
            } else if (fields.RecordType.DeveloperName === 'cellLine') {
                return getCellLineByBioTangId({ biotangId: fields.Id }).then((cellLine) => {
                    console.log("Cell Line", cellLine[0])
                    bodyData.disclosureBody.bioTangBody = {
                        "typeOfTP": "CellLine",
                        "nameOfTP": cellLine[0] ? jsonPropertyFromValue(cellLine[0].Name) : undefined
                    }

                    return bodyData
                }).catch((error) => {
                    console.log(error)
                })
            } else if (fields.RecordType.DeveloperName === 'plasmid') {
                return getPlasmidByBioTangId({ biotangId: fields.Id }).then((plasmid) => {
                    console.log("Plasmid", plasmid[0])
                    bodyData.disclosureBody.bioTangBody = {
                        "typeOfTP": "Plasmid",
                        "nameOfTP": plasmid[0] ? jsonPropertyFromValue(plasmid[0].Name) : undefined
                    }

                    return bodyData
                }).catch((error) => {
                    console.log(error)
                })
            } else if (fields.RecordType.DeveloperName === 'otherMaterial') {
                return getOtherMaterialByBioTangId({ biotangId: fields.Id }).then((otherMaterial) => {
                    console.log("Other Material", otherMaterial[0])
                    bodyData.disclosureBody.bioTangBody = {
                        "typeOfTP": "OtherMaterial",
                        "nameOfTP": otherMaterial[0] ? jsonPropertyFromValue(otherMaterial[0].Name) : undefined
                    }

                    return bodyData
                }).catch((error) => {
                    console.log(error)
                })
            }

            return null


        }).catch((error) => {
            console.log(error)
        })


    })


})

export { populateBioTangData }
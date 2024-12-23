@Metadata.allowExtensions: true
@EndUserText.label: 'Projection(consumption) CDS view entity'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity YC_MB11FILES
  provider contract transactional_query
  as projection on YR_MB11FILES
{
 
  key Scenario,
  key FilePurpose,
  ScenarioDescription,
  Attachment,
  Mimetype,
  Filename,
  Createdby,
  Createdat,
  Lastchangedby,
  Lastchangedat
  
}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Root CDS view entity '
define root view entity YR_MB11FILES
  as select from ymb11files as Files
{
  key scenario as Scenario,
  key file_purpose as FilePurpose,
  scenario_description as ScenarioDescription,
  time as Time,
  @Semantics.largeObject: {
    mimeType:'Mimetype',
    fileName: 'Filename',
    acceptableMimeTypes: [ 'text/csv' ],
    contentDispositionPreference: #ATTACHMENT
  }
  attachment as Attachment,
  @Semantics.mimeType: true
  mimetype as Mimetype,
  filename as Filename,
  @Semantics.user.createdBy: true
  createdby as Createdby,
  @Semantics.systemDateTime.createdAt: true
  createdat as Createdat,
  @Semantics.user.lastChangedBy: true
  lastchangedby as Lastchangedby,
  @Semantics.systemDateTime.lastChangedAt: true
  lastchangedat as Lastchangedat
  
}

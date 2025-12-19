[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared Country = "United States" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text, DefaultValue = ""];
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dimension_city_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "CityKey", DestinationColumnName = "CityKey"], [SourceColumnName = "WWICityID", DestinationColumnName = "WWICityID"], [SourceColumnName = "City", DestinationColumnName = "City"], [SourceColumnName = "StateProvince", DestinationColumnName = "StateProvince"], [SourceColumnName = "Country", DestinationColumnName = "Country"], [SourceColumnName = "Continent", DestinationColumnName = "Continent"], [SourceColumnName = "SalesTerritory", DestinationColumnName = "SalesTerritory"], [SourceColumnName = "Region", DestinationColumnName = "Region"], [SourceColumnName = "Subregion", DestinationColumnName = "Subregion"], [SourceColumnName = "Location", DestinationColumnName = "Location"], [SourceColumnName = "LatestRecordedPopulation", DestinationColumnName = "LatestRecordedPopulation"]}], DynamicSchema = true, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared dimension_city = let
    Source = Parquet.Document(
        AzureStorage.BlobContents(
            "https://fabrictutorialdata.blob.core.windows.net/sampledata/WideWorldImportersDW/tables/dimension_city.parquet"
        )
    ),
    FilteredRows = Table.SelectRows(Source, each [Country] = Country),
    RemovedColumns = Table.RemoveColumns(FilteredRows, {"ValidFrom", "ValidTo", "LineageKey"})
in
    RemovedColumns;
shared dimension_city_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "a6f7cb63-8ec0-4f7d-b368-d3277e9bded7"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "01cd0ac8-a366-4b71-9cbf-71965011efa6"]}[Data],
  TableNavigation = Navigation_2{[Id = "dimension_city", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;

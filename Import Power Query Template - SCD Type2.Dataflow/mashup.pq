[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared Dimension = let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("jVBBTgMxDPxLzpW2dhybHpHgBAdEC5fVHkLqQqU2K22X9vu1A0icEFGUjDWOZyZ9HyAsQgS08zXXonbf6aOO1cB6/Jw/LnqavaXDpW30dsAuQreyZcXm+eXe+RghopTEDKwcOUkh4kSFE+9YjYm8kyTENyLGRqEwLPqA7bGPvd1O++y6D/v6/iNftM5TPvzPgc0xVWAS5JX7sOrNkLL81nd3xnkXcGkuYhtALf25hd+M06QnA0+55mM2gB2QG6C/DNBXbOHv0GSiaEIeuKRl+xzgLUMYhis=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [SalesRepID = _t, RepSourceID = _t, FirstName = _t, LastName = _t, Region = _t, StartDate = _t, EndDate = _t, IsCurrent = _t, Hash = _t]),
  #"Changed column type" = Table.TransformColumnTypes(Source, {{"IsCurrent", type logical}, {"SalesRepID", Int64.Type}, {"RepSourceID", Int64.Type}, {"FirstName", type text}, {"LastName", type text}, {"Region", type text}, {"StartDate", type date}, {"EndDate", type date}, {"Hash", type text}})
in
  #"Changed column type";
shared SourceTable = let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMjY0UtJRCkvMS04F0i6pPqn5eUBGcH5pSUZ5anGJUqwOUJGxIVDMMaUoMxEk6Z2Zlw6k/PKLYGpiAQ==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [RepSourceID = _t, FirstName = _t, LastName = _t, Region = _t]),
  #"Changed column type" = Table.TransformColumnTypes(Source, {{"RepSourceID", Int64.Type}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type", "Hash", each Binary.ToText( Text.ToBinary( Text.Combine(List.Transform({[RepSourceID],[FirstName],[LastName],[Region]}, each if _ = null then "" else Text.From(_)), "|")), BinaryEncoding.Hex)), {{"Hash", type text}})
in
  #"Added custom";
shared AggregatedDimHash = let
  Source = Dimension,
  #"Grouped rows" = Table.Group(Source, {"Hash"}, {{"Count", each Table.RowCount(_), Int64.Type}})
in
  #"Grouped rows";
shared CompareStoM = let
  Source = Table.NestedJoin(SourceTable, {"Hash"}, AggregatedDimHash, {"Hash"}, "AggregatedDimHash", JoinKind.LeftOuter),
  #"Expanded AggregatedDimHash" = Table.ExpandTableColumn(Source, "AggregatedDimHash", {"Count"}, {"Count"}),
  #"Filtered rows" = Table.SelectRows(#"Expanded AggregatedDimHash", each ([Count] = null)),
  #"Removed columns" = Table.RemoveColumns(#"Filtered rows", {"Count"})
in
  #"Removed columns";
shared LastID = let
  Source = Dimension,
  #"Drill down" = Source[SalesRepID],
  #"Calculated maximum" = List.Max(#"Drill down"),
  Custom = try #"Calculated maximum" +1 otherwise 1
in
  Custom;
shared NewRecords = let
  Source = CompareStoM,
  #"Added index" = Table.AddIndexColumn(Source, "Index", LastID, 1, Int64.Type),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Added index", "StartDate", each Date.From(DateTime.LocalNow())), {{"StartDate", type date}}),
  #"Added custom 1" = Table.TransformColumnTypes(Table.AddColumn(#"Added custom", "EndDate", each #date(9999,12,31)), {{"EndDate", type date}}),
  #"Added custom 2" = Table.TransformColumnTypes(Table.AddColumn(#"Added custom 1", "IsCurrent", each true), {{"IsCurrent", type logical}}),
  #"Renamed columns" = Table.RenameColumns(#"Added custom 2", {{"Index", "SalesRepID"}})
in
  #"Renamed columns";
shared RecordsToUpdate = let
  Source = Table.NestedJoin(Dimension, {"Hash"}, SourceTable, {"Hash"}, "SourceTable", JoinKind.LeftAnti),
  #"Expanded SourceTable" = Table.ExpandTableColumn(Source, "SourceTable", {"Hash"}, {"Hash.1"}),
  #"Removed columns" = Table.RemoveColumns(#"Expanded SourceTable", {"Hash.1"}),
  #"Replaced value" = Table.ReplaceValue(#"Removed columns", true, false, Replacer.ReplaceValue, {"IsCurrent"}),
  #"Replaced value 1" = Table.ReplaceValue(#"Replaced value", #date(9999, 12, 31), Date.From(DateTime.LocalNow()), Replacer.ReplaceValue, {"EndDate"})
in
  #"Replaced value 1";
shared StagingTableForUpdates = let
  Source = Table.Combine({NewRecords, RecordsToUpdate}),
  #"Reordered columns" = Table.ReorderColumns(Source, {"SalesRepID", "RepSourceID", "FirstName", "LastName", "Region", "StartDate", "EndDate", "IsCurrent", "Hash"})
in
  #"Reordered columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Full Load_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "SalesRepID", DestinationColumnName = "SalesRepID"], [SourceColumnName = "RepSourceID", DestinationColumnName = "RepSourceID"], [SourceColumnName = "FirstName", DestinationColumnName = "FirstName"], [SourceColumnName = "LastName", DestinationColumnName = "LastName"], [SourceColumnName = "Region", DestinationColumnName = "Region"], [SourceColumnName = "StartDate", DestinationColumnName = "StartDate"], [SourceColumnName = "EndDate", DestinationColumnName = "EndDate"], [SourceColumnName = "IsCurrent", DestinationColumnName = "IsCurrent"], [SourceColumnName = "Hash", DestinationColumnName = "Hash"]}], DynamicSchema = true, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"Full Load" = let
  Source = Table.NestedJoin(Dimension, {"SalesRepID"}, RecordsToUpdate, {"SalesRepID"}, "RecordsToUpdate", JoinKind.LeftAnti),
  #"Expanded RecordsToUpdate" = Table.ExpandTableColumn(Source, "RecordsToUpdate", {"Hash"}, {"Hash.1"}),
  #"Removed columns" = Table.RemoveColumns(#"Expanded RecordsToUpdate", {"Hash.1"}),
  #"Appended query" = Table.Combine({#"Removed columns", StagingTableForUpdates}),
  #"Sorted rows" = Table.Sort(#"Appended query", {{"SalesRepID", Order.Ascending}})
in
  #"Sorted rows";
shared #"Full Load_DataDestination" = let
  Pattern = FabricSql.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "a6f7cb63-8ec0-4f7d-b368-d3277e9bded7"]}[Data],
  Navigation_2 = Navigation_1{[sqlId = "3d2c7091-d39a-4e81-b2e0-374cf709434c"]}[Data],
  TableNavigation = Navigation_2{[Item = "SCD_Type2_Full_Load", Schema = "dbo"]}?[Data]?
in
  TableNavigation;

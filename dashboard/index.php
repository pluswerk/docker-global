<?php

require_once("DataProcessor.php");
require_once("HtmlProcessor.php");

$containerDataProcessor = new DataProcessor();
$data = $containerDataProcessor->process();

$htmlProcessor = new HtmlProcessor($data);
$tableBody = $htmlProcessor->generateTableBody();
$table = $htmlProcessor->generateTable($tableBody);

echo $table;

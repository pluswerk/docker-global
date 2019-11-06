<?php

require_once("DataProcessor.php");

$containerDataProcessor = new DataProcessor();
$data = $containerDataProcessor->process();

$tbodyData = '';
foreach ($data as $dataEntry) {
    if (count($dataEntry['domains']) < 1) {
        $tbodyData .= '<tr><td>' . $dataEntry['name'] . '</td><td>' . $dataEntry['domains'][0] . '</td></tr>';
    }
    else {
        foreach ($dataEntry['domains'] as $index => $domain) {
            if ($index === 0) {
                $tbodyData .= '<tr><td>' . $dataEntry['name'] . '</td><td>' . $domain . '</td></tr>';
            }
            else {
                $tbodyData .= '<tr><td></td><td>' . $domain . '</td></tr>';
            }
        }
    }
}

$html = <<<HTML

<html lang="en">
    <body>
        <table>
            <thead>
                <tr><th>Container Name</th><th>Url(s)</th></tr>
            </thead>
            <tbody>
                {$tbodyData}
            </tbody>
        </table>
    </body>
</html>

HTML;

echo $html;

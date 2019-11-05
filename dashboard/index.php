<?php

$containerData = json_decode(shell_exec('sudo docker inspect $(sudo docker ps -q)'));
$data = [];

foreach ($containerData as $container) {
    $envVariableArray = preg_grep('/VIRTUAL_HOST=.*$/', $container->Config->Env);
    $virtualHostArray = [];
    if (!empty($envVariableArray)) {
        $virtualHostEnv = $envVariableArray[0];
        $virtualHosts = explode('=', $virtualHostEnv)[1];
        $virtualHostArray = [$virtualHosts];
        if (strpos($virtualHosts, ',') !== false){
            $virtualHostArray = explode(',', $virtualHosts);
        }
    }
    $dataEntry = ['name' => $container->Name, 'domains' => $virtualHostArray];
    array_push($data, $dataEntry);
}


$tbodyData = '';
foreach ($data as $dataEntry) {
    $tbodyData .= '<tr><td>' . $dataEntry['name'] . '</td>';
    foreach ($dataEntry['domains'] as $domain) {
        $tbodyData .= '<td><a href="https://' . $domain .'">'. $domain . '</a></td>';
    }
    $tbodyData .= '</tr>';
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

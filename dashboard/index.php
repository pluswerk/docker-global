<?php

exec('sudo docker ps -q', $containers);
$data = [];

foreach ($containers as $container) {
    $containerInspectCmd = "sudo docker inspect --format='{{json .}}' " . $container;
    $containerInfo = json_decode(shell_exec($containerInspectCmd));
    $envVariableArray = preg_grep('/VIRTUAL_HOST=.*$/', $containerInfo->Config->Env);
    $virtualHostArray = [];
    if (!empty($envVariableArray)) {
        $virtualHostEnv = $envVariableArray[0];
        $virtualHosts = explode('=', $virtualHostEnv)[1];
        $virtualHostArray = [$virtualHosts];
        if (strpos($virtualHosts, ',')){
            $virtualHostArray = explode(',', $virtualHosts);
        }
    }
    $dataEntry = ['name' => $containerInfo->Name, 'domains' => $virtualHostArray];
    array_push($data, $dataEntry);
}

$html = '<table><thead><tr><th>Container Name</th><th>Url(s)</th></tr></thead><tbody>';

foreach ($data as $dataEntry) {
    $html .= '<tr><td>' . $dataEntry['name'] . '</td>';
    foreach ($dataEntry['domains'] as $domain) {
        $html .= '<td><a href="https://' . $domain .'">'. $domain . '</a></td>';
    }
    $html .= '</tr>';
}

$html .= '</tbody></table>';

echo $html;

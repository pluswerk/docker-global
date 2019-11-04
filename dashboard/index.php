<?php

exec('sudo docker ps -q', $containers);
$data = [];

foreach ($containers as $container) {
    $containerNameCmd = "sudo docker inspect --format '{{.Name}}' " . $container;
    $containerConfigCmd = "sudo docker inspect --format '{{.Config.Env}}' " . $container;
    $resultName = shell_exec($containerNameCmd);
    $resultConfig = shell_exec($containerConfigCmd);
    $resultConfig = explode(' ', $resultConfig);
    $envVariableArray = preg_grep('/VIRTUAL_HOST=.*$/', $resultConfig);
    if (empty($envVariableArray)) {
        $data[$resultName] = ' ';
    } else {
        $virtualHostArray = $envVariableArray[0];
        $virtualHost = explode('=', $virtualHostArray)[1];
        $data[$resultName] = $virtualHost;
    }
}

$html = '<table><thead><tr><th>Container Name</th><th>URL</th></tr></thead><tbody>';
foreach ($data as $containerName => $vHost) {
    $html .= '<tr><td>' . $containerName . '</td><td><a href="https://' . $vHost . '">' . $vHost . '</a></td>';
}
$html .= '</tbody></table>';

echo $html;

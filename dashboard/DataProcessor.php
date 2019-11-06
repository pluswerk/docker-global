<?php


class DataProcessor
{
    public $jsonContainerData;
    public $processedData;

    public function __construct() {
        $this->jsonContainerData = json_decode(shell_exec('sudo docker inspect $(sudo docker ps -qa)'));
        $this->processedData = [];
    }

    public function getVirtualHostEnvVariable($container) {
        return preg_grep('/VIRTUAL_HOST=.*$/', $container->Config->Env);
    }

    public function processVirtualHostEnvVariable($envVariableArray) {
        if (!empty($envVariableArray)) {
            $virtualHostEnv = $envVariableArray[0];
            $virtualHosts = explode('=', $virtualHostEnv)[1];
            $virtualHostArray = [$virtualHosts];
            if (strpos($virtualHosts, ',') !== false){
                $virtualHostArray = explode(',', $virtualHosts);
            }
            return $virtualHostArray;
        }
        return [];
    }

    public function process() {
        foreach ($this->jsonContainerData as $container){
            $virtualHostsEnvArray = $this->getVirtualHostEnvVariable($container);
            $virtualHosts = $this->processVirtualHostEnvVariable($virtualHostsEnvArray);
            $dataEntry = ['name' => $container->Name, 'domains' => $virtualHosts];
            array_push($this->processedData, $dataEntry);
        }
        return $this->processedData;
    }
}

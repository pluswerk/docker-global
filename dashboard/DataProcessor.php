<?php


class DataProcessor
{
    protected $jsonContainerData;
    protected $processedData = [];

    public function __construct() {
        $this->jsonContainerData = json_decode(shell_exec('sudo docker inspect $(sudo docker ps -qa)'));
    }

    protected function getVirtualHostEnvVariable($container): array {
        return preg_grep('/VIRTUAL_HOST=.*$/', $container->Config->Env);
    }

    protected function processVirtualHostEnvVariable($envVariableArray): array {
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

    public function process(): array {
        foreach ($this->jsonContainerData as $container){
            $virtualHostsEnvArray = $this->getVirtualHostEnvVariable($container);
            $virtualHosts = $this->processVirtualHostEnvVariable($virtualHostsEnvArray);
            $dataEntry = ['name' => $container->Name, 'domains' => $virtualHosts];
            $this->processedData[] = $dataEntry;
        }
        return $this->processedData;
    }
}

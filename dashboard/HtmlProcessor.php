<?php


class HtmlProcessor
{
    protected $tableBodyData;

    public function __construct(array $tableBodyDataParam) {
        $this->tableBodyData = $tableBodyDataParam;
    }

    protected function createOneRow(array $dataItem) {
        return '<tr><td>'. $dataItem['name']. '</td><td>' . $dataItem['domains'][0] . '</td></tr>';
    }

    protected function createMultipleRows(array $dataItem) {
        $rows = null;
        foreach ($dataItem['domains'] as $index => $domain) {
            if ($index === 0) {
                $rows .= '<tr><td>' . $dataItem['name'] . '</td><td>' . $domain . '</td></tr>';
            }
            else {
                $rows .= '<tr><td></td><td>' . $domain . '</td></tr>';
            }
        }
        return $rows;
    }

    public function generateTableBody() {
        $htmlTableRows = null;
        foreach ($this->tableBodyData as $tableRow) {
            if (count($tableRow['domains']) === 1) {
                $htmlTableRows .= $this->createOneRow($tableRow);
            }
            else {
                $htmlTableRows .= $this->createMultipleRows($tableRow);
            }
        }
        return $htmlTableRows;
    }

    public function generateTable($tableBody) {
        return <<<HTML
            <html lang="en">
                <body>
                    <table>
                        <thead>
                            <tr><th>Container Name</th><th>Url(s)</th></tr>
                        </thead>
                        <tbody>
                            {$tableBody}
                        </tbody>
                    </table>
                </body>
            </html>
        HTML;
    }

}

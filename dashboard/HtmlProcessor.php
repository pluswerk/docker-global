<?php


class HtmlProcessor
{
    protected $tableBodyData;

    public function __construct(array $tableBodyDataParam) {
        $this->tableBodyData = $tableBodyDataParam;
    }

    protected function createOneRow(array $dataItem): string {
        return '<tr><td>'. $dataItem['name']. '</td><td><a href="https://'. $dataItem['domains'][0]. '">' . $dataItem['domains'][0] . '</a></td></tr>';
    }

    protected function createMultipleRows(array $dataItem): string {
        $rows = '';
        foreach ($dataItem['domains'] as $index => $domain) {
            if ($index === 0) {
                $rows .= '<tr><td>' . $dataItem['name'] . '</td><td><a href="https://'. $domain. '">' . $domain . '</a></td></tr>';
            }
            else {
                $rows .= '<tr><td></td><td><a href="https://'. $domain. '">' . $domain . '</a></td></tr>';
            }
        }
        return $rows;
    }

    public function generateTableBody(): string {
        $htmlTableRows = '';
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

    public function generateTable(string $tableBody): string {
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

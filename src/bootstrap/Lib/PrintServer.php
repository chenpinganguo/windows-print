<?php

namespace Lib;

use Dompdf\Dompdf;
use Mike42\Escpos\GdEscposImage;
use Mike42\Escpos\PrintConnectors\WindowsPrintConnector;
use Mike42\Escpos\Printer;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;

/**
 * Created by PhpStorm.
 * User: CodeAnti
 * Date: 2018/4/12
 * Time: 9:21
 */
class PrintServer implements MessageComponentInterface
{
    const CODE_SUCCESS = '100000';
    const CODE_ERROR   = '200000';
    const MSG_SUCCESS  = 'SUCCESS';
    const MSG_ERROR    = 'ERROR';

    const TYPE_PRINTER_LIST = 'PRINTER_LIST'; // 打印机列表
    const TYPE_PRINT_ORDER  = 'PRINT_ORDER';  // 订单打印

    public function onOpen(ConnectionInterface $conn)
    {
        $data = [
            'code'    => self::CODE_SUCCESS,
            'message' => self::MSG_SUCCESS,
            'type'    => self::TYPE_PRINTER_LIST,
            'data'    => $this->printerList()
        ];
        $conn->send(json_encode($data));
    }

    public function onMessage(ConnectionInterface $conn, $msg)
    {
        try {
            $msg = json_decode($msg, true);
            switch ($msg['type']) {
                case self::TYPE_PRINT_ORDER:
                    $this->printOrder($msg['printer'], $msg['data']);
                    $conn->send(json_encode([
                        'code'    => self::CODE_SUCCESS,
                        'message' => self::MSG_SUCCESS,
                        'type'    => self::TYPE_PRINT_ORDER
                    ]));
                    break;
                default:
                    break;
            }
        } catch (\Exception $e) {
            $conn->send($e->getMessage());
        }
    }

    public function onClose(ConnectionInterface $conn)
    {
        $conn->close();
    }

    public function onError(ConnectionInterface $conn, \Exception $e)
    {
        $conn->close();
    }

    /**
     * 获取打印机列表
     * @return array
     * @author CodeAnti
     */
    private function printerList()
    {
        $printerList = [];
        $wmi = new \COM('winmgmts://');
        $printers = $wmi->ExecQuery("SELECT * FROM Win32_Printer");
        foreach ($printers as $printer) {
            array_push($printerList, $printer->Name);
        }
        return $printerList;
    }

    /**
     * 打印订单
     *
     * @param $printer
     * @param $order
     *
     * @return array
     * @throws \Exception
     * @author CodeAnti
     */
    private function printOrder($printer, $html)
    {
        try {
            $printer = new Printer(new WindowsPrintConnector($printer));

            $gdImg = new GdEscposImage('./demo.png');
            $printer->bitImage($gdImg);

            $printer->cut();
            $printer->pulse();
            $printer->close();
        } catch (\Exception $e) {
            throw $e;
        }
    }

    /**
     * 重写str_pad方法，使中英文可以等边
     *
     * @param $input
     * @param $pad_length
     * @param $pad_string
     * @param $pad_type
     *
     * @return string
     */
    private function str_pad($input, $pad_length, $pad_string, $pad_type)
    {
        $strLen = (strlen($input) + mb_strlen($input, 'UTF8')) / 2;
        if ($strLen < $pad_length) {
            $difference = $pad_length - $strLen;
            switch ($pad_type) {
                case STR_PAD_RIGHT:
                    return $input.str_repeat($pad_string, $difference);
                    break;
                case STR_PAD_LEFT:
                    return str_repeat($pad_string, $difference).$input;
                    break;
                default:
                    $left = $difference / 2;
                    $right = $difference - $left;
                    return str_repeat($pad_string, $left).$input.str_repeat($pad_string, $right);
                    break;
            }
        } else {
            return $input;
        }
    }
}

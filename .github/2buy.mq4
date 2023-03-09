//+------------------------------------------------------------------+
//|                                                     Example.mq4 |
//|                         Copyright 2023, ChatGPT, All rights res. |
//|                                             https://chatgpt.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, ChatGPT"
#property link      "https://chatgpt.com/"
#property version   "1.00"
#property strict

// Parámetros de entrada
extern double Lots = 0.01;           // Tamaño de lote
extern double StopLoss = 50;         // Stop Loss en puntos
extern double TakeProfit = 100;       // Take Profit en puntos
extern int Slippage = 3;             // Deslizamiento permitido en puntos

// Variables globales
int buyStopTicket = -1;              // Ticket de la orden Buy Stop
int sellStopTicket = -1;             // Ticket de la orden Sell Stop
int lastClosedTicket = -1;           // Ticket de la última orden cerrada

void OnTick()
{
    // Si no hay órdenes abiertas
    if (OrdersTotal() == 0)
    {
        // Abre una orden Buy Stop
        double buyStopPrice = Ask + 50 * Point;
        buyStopTicket = OrderSend(Symbol(), OP_BUYSTOP, Lots, buyStopPrice, Slippage, buyStopPrice - StopLoss * Point, buyStopPrice + TakeProfit * Point, "Buy Stop", 0, 0, Green);
        
        // Abre una orden Sell Stop
        double sellStopPrice = Bid - 50 * Point;
        sellStopTicket = OrderSend(Symbol(), OP_SELLSTOP, Lots, sellStopPrice, Slippage, sellStopPrice + StopLoss * Point, sellStopPrice - TakeProfit * Point, "Sell Stop", 0, 0, Red);
    }
    // Si hay órdenes abiertas
    else
    {
        // Busca la última orden cerrada
        if (lastClosedTicket == -1)
        {
            for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
            {
                if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
                {
                    if (OrderCloseTime() != 0)
                    {
                        lastClosedTicket = OrderTicket();
                        break;
                    }
                }
            }
        }
        
        // Si una orden se cerró, abre una nueva orden con los mismos parámetros
        if (lastClosedTicket == buyStopTicket || lastClosedTicket == sellStopTicket)
        {
            double price;
            int type;
            if (lastClosedTicket == buyStopTicket)
            {
                price = Ask + 50 * Point;
                type = OP_BUYSTOP;
            }
            else if (lastClosedTicket == sellStopTicket)
            {
                price = Bid - 50 * Point;
                type = OP_SELLSTOP;
            }
            
            int newTicket = OrderSend(Symbol(), type, Lots, price, Slippage, price - StopLoss * Point, price + TakeProfit * Point, "New Order", 0, 0, Blue);
            
            // Reinicia la variable de última orden cerrada
            lastClosedTicket = -1;
        }
    }
}

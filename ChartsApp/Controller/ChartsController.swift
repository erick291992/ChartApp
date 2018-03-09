//
//  ChartsController.swift
//  ChartsApp
//
//  Created by Erick Manrique on 3/8/18.
//  Copyright © 2018 Erick Manrique. All rights reserved.
//

import UIKit
import Charts

class ChartsController: UIViewController {
    
    @IBOutlet weak var chartLineChartView: LineChartView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var currencies = [Currency]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Currencies.BTC
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = .orange
        requestCoinData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestCoinData() {
        activityIndicatorView.startAnimating()
        //requesting BTC data
        //BTC and USD are hardcoded but can be modified to any currency
        NetworkClient.shared.getCurrencyData(fsym: Currencies.BTC, tsym: Currencies.USD) { (currencies, err) in
            if err != nil {
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicatorView.stopAnimating()
                }
            } else {
                guard let currencies = currencies else {
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    self?.currencies = currencies
                    self?.updateGraph()
                    self?.activityIndicatorView.stopAnimating()
                }
            }
            
        }
    }
    
    func updateGraph() {
        //array that will hold coordinates
        var lineChartEntryHigh  = [ChartDataEntry]()
        var lineChartEntryLow  = [ChartDataEntry]()
        
        for i in 0..<currencies.count {
            //setting x and y coordinates that we will be graphing
            var value = ChartDataEntry(x: Double(i), y: currencies[i].high)
            lineChartEntryHigh.append(value)
            
            value = ChartDataEntry(x: Double(i), y: currencies[i].low)
            lineChartEntryLow.append(value)
        }
        
        let line1 = LineChartDataSet(values: lineChartEntryHigh, label: "\(Currencies.BTC) High")
        line1.mode = .cubicBezier
        line1.colors = [NSUIColor.blue] //Setting the color
        
        let line2 = LineChartDataSet(values: lineChartEntryLow, label: "\(Currencies.BTC) Low")
        line2.mode = .cubicBezier
        line2.colors = [NSUIColor.cyan]
        
        //maind object that will be added to the chart
        let data = LineChartData()
        //adding lines to the data object
        data.addDataSet(line1)
        data.addDataSet(line2)
        data.setDrawValues(true)
        
        //adding line chart data to chart view
        chartLineChartView.data = data
        chartLineChartView.chartDescription?.text = "\(Currencies.BTC) Chart"
        chartLineChartView.xAxis.labelPosition = .bottom
        chartLineChartView.rightAxis.enabled = false
        
    }
    
}

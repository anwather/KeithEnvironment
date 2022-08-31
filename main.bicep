@secure()
param adminPassword string
param location string

var prefix = 'keithbl'

var vmNames = [
  'vm01'
  'vm02'
  'vm03' ]

var nicNames = [
  'nic01'
  'nic02'
  'nic03' ]

var sqlDBNames = [
  'db01'
  'db02'
  'db03' ]

resource nic 'Microsoft.Network/networkInterfaces@2022-01-01' = [for nic in nicNames: {
  name: '${prefix}-${nic}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: vnet.properties.subnets[0]
        }
      }
    ]
  }
}]

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: '${prefix}-vnet01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.0.0.0/24' ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource vms 'Microsoft.Compute/virtualMachines@2022-03-01' = [for (vm, i) in vmNames: {
  name: '${prefix}-${vm}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-smalldisk-g2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic[i].id
        }
      ]
    }
    osProfile: {
      adminUsername: 'keithbl'
      computerName: '${prefix}-${vm}'
      adminPassword: adminPassword
    }
  }
}]

resource sqlserver 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: '${prefix}-sql01'
  location: location
  properties: {
    administratorLogin: 'keithbl'
    administratorLoginPassword: adminPassword
  }
}

resource dbs 'Microsoft.Sql/servers/databases@2022-02-01-preview' = [for db in sqlDBNames: {
  name: '${prefix}-${db}'
  parent: sqlserver
  location: location
  sku: {
    tier: 'Basic'
    name: 'Basic'
  }
  properties: {
    sampleName: 'AdventureWorksLT'
  }
}]

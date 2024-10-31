import 'package:build_growth_mobile/pages/financial/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:build_growth_mobile/models/asset.dart';

class AssetDetailPage extends StatefulWidget {
  const AssetDetailPage({super.key});

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  List<Asset> assets = [];

  @override
  void initState() {
    super.initState();
    loadAssets();
  }

  Future<void> loadAssets() async {
    assets = await Asset.getAssetList();
    setState(() {});
  }

 void showActionSheet(Asset asset) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Text(asset.name),
      message: Text('\$${asset.value.toStringAsFixed(2)}'),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            showEditAssetDetailsDialog(asset);
          },
          child: const Text('Edit Asset Details'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            navigateToTransactionPage(asset);
          },
          child: const Text('Make Transaction'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            showDeleteConfirmationDialog(asset); // Show confirmation dialog for deletion
          },
          child: const Text('Delete Asset', style: TextStyle(color: Colors.red)),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel'),
      ),
    ),
  );
}

void showDeleteConfirmationDialog(Asset asset) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${asset.name}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await Asset.deleteAsset(asset.id!,false); // soft Delete the asset
              await loadAssets(); // Refresh the asset list
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}


  void showEditAssetDetailsDialog(Asset asset) {
    final TextEditingController nameController =
        TextEditingController(text: asset.name);
    final TextEditingController descController =
        TextEditingController(text: asset.desc);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Asset Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Asset Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                asset.name = nameController.text;
                asset.desc = descController.text;
                await Asset.updateAsset(asset);
                await loadAssets();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void navigateToTransactionPage(Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage(
          asset: asset,
          type: "Asset",
        ),
      ),
    ).then((_) =>
        loadAssets()); // Refresh assets when returning from transaction page
  }

  Widget AssetDetailCard(Asset asset) {
    return GestureDetector(
      onTap: () => showActionSheet(asset),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              asset.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (asset.desc.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                asset.desc,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '\$${asset.value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddAssetDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: assets.map((asset) => AssetDetailCard(asset)).toList(),
        ),
      ),
    );
  }

  void showAddAssetDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController valueController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    String selectedType = 'Cash'; // Default asset type
    bool status = true; // Default status

    final List<String> assetTypes = ['Cash', 'Bank Card', 'Property','Stock','Digital Asset','Others'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Asset'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Asset Name'),
                ),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Value'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: assetTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Asset Type'),
                ),
               
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Asset newAsset = Asset(
                  'user_code', // Replace with actual user code if applicable
                  name: nameController.text,
                  value: double.tryParse(valueController.text) ?? 0.0,
                  desc: descController.text,
                  type: selectedType,
                  status: true,
                );

                await Asset.insertAsset(
                    newAsset); // Insert asset into the database
                loadAssets();
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

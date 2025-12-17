import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(45, 147, 243, 1),
          foregroundColor: const Color.fromRGBO(245, 245, 244, 1),
          centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          title: const Text(
            "Claims",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [IconButton(icon: const Icon(Icons.sort), onPressed: () {})],
        ),
        body: const SafeArea(child: ClaimsListScreen()),
      ),
    );
  }
}

class Claim {
  final String claimNo;
  final String insurer;
  final String name;
  final String address;
  final String city;
  final String receivedDate;
  final String preInspectionDate;
  final String contactDate;
  final String inspectionDate;

  Claim({
    required this.claimNo,
    required this.insurer,
    required this.name,
    required this.address,
    required this.city,
    required this.receivedDate,
    required this.preInspectionDate,
    required this.contactDate,
    required this.inspectionDate,
  });
}

final List<Claim> dummyClaims = List.generate(
  10,
  (index) => Claim(
    claimNo: "TEST0623-${index + 1}",
    insurer: "Rheal Insurance",
    name: "Narhe",
    address: "Address Three",
    city: "City",
    receivedDate: "2021-06-23",
    preInspectionDate: "2021-06-24",
    contactDate: "2024-11-22",
    inspectionDate: "2024-05-19",
  ),
);

class ClaimsListScreen extends StatelessWidget {
  const ClaimsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dummyClaims.length,
      itemBuilder: (context, index) {
        return ClaimExpandableCard(claim: dummyClaims[index]);
      },
    );
  }
}

class ClaimExpandableCard extends StatefulWidget {
  final Claim claim;

  const ClaimExpandableCard({super.key, required this.claim});

  @override
  State<ClaimExpandableCard> createState() => _ClaimExpandableCardState();
}

class _ClaimExpandableCardState extends State<ClaimExpandableCard> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.all(16),
        color: const Color.fromARGB(255, 195, 230, 255),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Claim Status : ",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "Docs Uploaded",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(45, 147, 243, 1),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Colors.black26),
              ),

              /// SUMMARY (ALWAYS VISIBLE)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.claim.claimNo,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(widget.claim.insurer),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.claim.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(widget.claim.address),
                          Text(widget.claim.city),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// DETAILS (EXPANDABLE)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child:
                    isExpanded
                        ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Received Date",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(widget.claim.receivedDate),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Prel. Insp. Date",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(widget.claim.preInspectionDate),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Contact Date",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(widget.claim.contactDate),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Insp. Date",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(widget.claim.inspectionDate),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox(),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Divider(color: Colors.black26),
              ),

              /// TOGGLE BUTTON
              Center(
                child: IconButton(
                  icon: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.expand_more),
                  ),
                  onPressed: () {
                    setState(() => isExpanded = !isExpanded);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharetraveyard/models/associate_model.dart';
import 'package:sharetraveyard/models/site_code_model.dart';
import 'package:sharetraveyard/states/main_home.dart';
import 'package:sharetraveyard/utility/app_constant.dart';
import 'package:sharetraveyard/utility/app_controller.dart';
import 'package:sharetraveyard/widgets/widget_buttom.dart';
import 'package:sharetraveyard/widgets/widget_progress.dart';
import 'package:sharetraveyard/widgets/widget_text.dart';

class SelectSite extends StatefulWidget {
  const SelectSite({super.key});

  @override
  State<SelectSite> createState() => _SelectSiteState();
}

class _SelectSiteState extends State<SelectSite> {
  AppController controller = Get.put(AppController());

  @override
  void initState() {
    super.initState();
    controller.readSiteCode();
    controller.readPeriod();
    findUserLogin();
  }

  Future<void> findUserLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? user = preferences.getString('user');
    print('findUserLogin --> $user');

    await FirebaseFirestore.instance
        .collection('associate')
        .doc(user)
        .get()
        .then((value) async {
      AsscociateModel asscociateModel = AsscociateModel.fromMap(value.data()!);
      String docIdSiteCode = asscociateModel.docIdSiteCode;
      print('docIdSiteCode ---> $docIdSiteCode');
      await FirebaseFirestore.instance
          .collection('sitecode')
          .doc(docIdSiteCode)
          .get()
          .then((value) {
        SiteCodeModel siteCodeModel = SiteCodeModel.fromMap(value.data()!);
        print('siteCodeModel ---->${siteCodeModel.toMap()}');
        controller.displaySiteCode.value = siteCodeModel.name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.bgColor,
      body: GetX(
          init: AppController(),
          builder: (AppController appController) {
            print('## pperiod --> ${appController.periodModels}');
            print('## Sitecode --> ${appController.siteCodeModel}');

            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    sitecode(),
                    appController.displaySiteCode.isEmpty
                        ? const SizedBox()
                        : WidgetText(
                            text: appController.displaySiteCode.value,
                            textStyle: AppConstant().h2Style(),
                          ),

                    // dropdown(appController),
                    //period1(),
                    //dropdownperiod(appController),
                    clickbuttomGoToShop()
                    
                  ],
                ),
              ),
            );
          }),
    );
  }

  WidgetButtom clickbuttomGoToShop() {
    return WidgetButtom(label: 'Go to Shop', pressFunc:() {
                     Get.to(MainHome());
                    
                  },);
  }

  Container dropdownperiod(AppController appController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(left: 50, right: 50, top: 16, bottom: 30),
      width: double.infinity,
      height: 50,
      color: AppConstant.fieldColor,
      child: appController.periodModels.isEmpty
          ? const WidgetProgress()
          : Center(
              child: DropdownButton(
                isExpanded: true,
                hint: WidgetText(text: 'Palease Choose number'),
                value: appController.choosePeriod.isEmpty
                    ? null
                    : appController.choosePeriod.last,
                items: appController.periodModels
                    .map(
                      (element) => DropdownMenuItem(
                        child: WidgetText(text: element.period),
                        value: element.period,
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  appController.choosePeriod.add(value!);
                  Get.to(MainHome());
                },
              ),
            ),
    );
  }

  Container period1() {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 20),
      child: WidgetText(
        text: '!!! Click !!!',
        textStyle:
            AppConstant().appStyle(size: 30, fontWeight: FontWeight.bold),
      ),
    );
  }

  WidgetText sitecode() {
    return WidgetText(
      text: 'Select Site',
      textStyle: AppConstant().appStyle(
        size: 48,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Container dropdown(AppController appController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 20),
      width: double.infinity,
      height: 50,
      color: AppConstant.fieldColor,
      child: appController.siteCodeModel.isEmpty
          ? const WidgetProgress()
          : DropdownButton(
              isExpanded: true,
              hint: WidgetText(text: 'Palease Choose Site Code'),
              value: appController.chooseSiteCode.isEmpty
                  ? null
                  : appController.chooseSiteCode.last,
              items: appController.siteCodeModel
                  .map(
                    (element) => DropdownMenuItem(
                      child: WidgetText(text: element.name),
                      value: element.name,
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                appController.chooseSiteCode.add(value!);
              },
            ),
    );
  }
}

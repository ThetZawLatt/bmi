import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bmi/data/network/response_vo/login_response_vo.dart';
import 'package:bmi/screen/home/market_price.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/network/data_agent/login/login_data_agent.dart';
import '../data/network/data_agent/login/login_data_agent_impl.dart';

class LoginProvider extends ChangeNotifier {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  LoginDataAgent loginDataAgent = LoginDataAgentImpl();

  bool loading = false;
  int? buyerID;
  int? buyerType;
  String? phone, address, name;

  enableLoading() {
    loading = true;
    notifyListeners();
  }

  disableLoading() {
    loading = false;
    notifyListeners();
  }

  doLogin(String phoneNumber, String password, BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("Here is request phone 09$phoneNumber");
    loginDataAgent.doLogin("09$phoneNumber", password).then((value) {
      disableLoading();
      if (value.code == 200) {
        buyerID = value.data?.id;
        name = value.data?.name;
        sharedPreferences.setInt("seller_type", value.data?.sellerID ?? 1);
        sharedPreferences.setInt("seller_id", buyerID ?? 1);
        sharedPreferences.setBool("isLogin", true);
        sharedPreferences.setString("name", name ?? "");
        sharedPreferences.setString("phone", "09$phoneNumber");
        sharedPreferences.setString("address", value.data?.address ?? "");
        print("Login Data $name $phoneNumber ${value.data?.address}");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MarketPriceScreen()),
            (Route<dynamic> route) => false);
        disableLoading();
      } else if (value.code == 422) {
        disableLoading();
        AwesomeDialog(
          dialogType: DialogType.error,
          context: context,
          desc: "အကောင့်အချက်အလက် မှားယွင်းနေပါသည်",
          btnOkOnPress: () {},
        ).show();
      }
    }).onError((error, stackTrace) {
      if (kDebugMode) {
        print(error);
      }
    });
  }
}

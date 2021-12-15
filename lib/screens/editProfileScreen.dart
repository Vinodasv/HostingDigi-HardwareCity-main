import '../customicons.dart';
import 'package:flutter/material.dart';
import '../styles.dart' as styles;
import '../constants.dart' as Constants;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../states/customerProfileState.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/cupertino.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isLoading = true;
  String firstName = '';
  String mailID = '';
  String lastName = '';
  String company = '';
  String phone = '';
  String fax = '';
  String address1 = '';
  String address2 = '';
  String zipCode = '';
  String companyName = '';
  int? customerId;
  File? _image;

  // final picker = ImagePicker();

  // Future uploadImage(type) async {
  //   Navigator.pop(context);
  //   var pickedFile;
  //   if (type == 'camera') {
  //     pickedFile = await picker.getImage(source: ImageSource.camera);
  //   } else {
  //     pickedFile = await picker.getImage(source: ImageSource.gallery);
  //   }

  //   setState(() {
  //     img = pickedFile.path;
  //     _image = File(pickedFile.path);
  //   });
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setString('images', img);
  // }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      print("called");
      this._checkLogin();
    });
  }

  _checkLogin() async {
    print("called");
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    print(loginuserResponse);
    print(loginuserResponse['isLogin']);

    if (loginuserResponse['isLogin']) {
      setState(() {
        customerId = loginuserResponse["customerInfo"]["cust_id"];
        firstName = loginuserResponse['customerInfo']["cust_firstname"];
        lastName = loginuserResponse['customerInfo']["cust_lastname"];
        mailID = loginuserResponse['customerInfo']["cust_email"];
        zipCode = loginuserResponse['customerInfo']["cust_zip"];
      });
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(Constants.logocolor),

          //backgroundColor: Color(0x44ffffff),
          elevation: 0,
          title: Text(
            "Edit profile",
            style: styles.ThemeText.appbarTextStyles2,
          ),
          leading: IconButton(
            icon: Icon(CustomIcons.backarrow,
                color: Color(Constants.primaryYellow)),
            onPressed: () => Navigator.pop(context, "edited"),
          ),
          actions: <Widget>[
            // add the icon to this list
            // StatusWidget(),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    width: pageWidth,
                    child: Stack(children: [
                      Container(
                        width: pageWidth,
                        height: 96,
                        color: Colors.grey[200],
                      ),
                      Center(
                          child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 15),
                          child: Stack(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(300),
                                child: _image != null
                                    ? Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                        height: 115.92,
                                        width: 115.92,
                                      )
                                    : Image.asset(
                                        "assets/images/user.png",
                                        fit: BoxFit.cover,
                                        height: 115.92,
                                        width: 115.92,
                                      )),
                            // Positioned(
                            //   bottom: 7,
                            //   right: 0,
                            //   child: ClipOval(
                            //     child: Material(
                            //       color: Color(
                            //           Constants.primaryYellow), // button color
                            //       child: InkWell(
                            //         splashColor: Colors.grey, // inkwell color
                            //         child: SizedBox(
                            //             width: 38,
                            //             height: 38,
                            //             child: Icon(Icons.edit)),
                            //         onTap: () {
                            //           PlatformActionSheet().displaySheet(
                            //               context: context,
                            //               message: Padding(
                            //                   padding:
                            //                       const EdgeInsets.only(top: 10),
                            //                   child: Text("Select your option")),
                            //               actions: [
                            //                 ActionSheetAction(
                            //                   text: 'Camera',
                            //                   onPressed: () =>
                            //                       uploadImage('camera'),
                            //                   hasArrow: true,
                            //                 ),
                            //                 ActionSheetAction(
                            //                   text: "Gallery",
                            //                   onPressed: () =>
                            //                       uploadImage('gallery'),
                            //                   hasArrow: true,
                            //                 ),
                            //                 ActionSheetAction(
                            //                   text: "Cancel",
                            //                   onPressed: () =>
                            //                       Navigator.pop(context),
                            //                   isCancel: true,
                            //                   defaultAction: true,
                            //                 )
                            //               ]);
                            //         },
                            //       ),
                            //     ),
                            //   ),
                            // )
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                              firstName == null && lastName == null
                                  ? ''
                                  : firstName + " " + lastName,
                              style: styles.ThemeText.editProfileText),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mail_outline),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(mailID == null ? "" : mailID,
                                  style: styles.ThemeText.editProfileText2),
                            ),
                          ],
                        ),
                        Container(
                          width: pageWidth / 2.5,
                          height: 30,
                          margin: EdgeInsets.only(top: 10),
                          child: FlatButton(
                            padding: EdgeInsets.all(5),
                            onPressed: () {
                              Navigator.pushNamed(context, '/changePass');
                            },
                            child: Align(
                              child: Text(
                                'Change password?',
                                style: styles.ThemeText.buttonTextStyles,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ]))
                    ])),
                FormForEditProfile()
              ],
            ),
          ),
        ));
  }
}

class FormForEditProfile extends StatefulWidget {
  @override
  _FormForEditProfileState createState() => _FormForEditProfileState();
}

class _FormForEditProfileState extends State<FormForEditProfile> {
  bool isLoading = false;
  String firstName = '';
  String mailID = '';
  String lastName = '';
  String company = '';
  String phone = '';
  String fax = '';
  String address1 = '';
  String address2 = '';
  String zipCode = '';
  String companyName = '';
  int? customerId;
  String editPhone = '';
  final _formKey = GlobalKey<FormState>();
  Country _selectedCupertinoCountry =
      CountryPickerUtils.getCountryByIsoCode("SG");
  String phCode = "";
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10), () {
      print("called");
      this.getData();
    });
  }

  openModal() {
    _openCupertinoCountryPicker();
  }

  _openCupertinoCountryPicker() => showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CountryPickerCupertino(
          backgroundColor: Colors.white,
          itemBuilder: _buildCupertinoItem,
          pickerSheetHeight: 300.0,
          pickerItemHeight: 75,
          initialCountry: _selectedCupertinoCountry,
          onValuePicked: (Country country) =>
              setState(() => _selectedCupertinoCountry = country),
        );
      });

  getData() {
    print("called");
    final AuthState authState = Provider.of<AuthState>(context, listen: false);
    dynamic loginuserResponse = authState.getLoginUser;
    print(loginuserResponse);
    print(loginuserResponse['isLogin']);

    if (loginuserResponse['isLogin']) {
      setState(() {
        customerId = loginuserResponse["customerInfo"]["cust_id"];
        firstName = loginuserResponse['customerInfo']["cust_firstname"];
        lastName = loginuserResponse['customerInfo']["cust_lastname"];
        mailID = loginuserResponse['customerInfo']["cust_email"];
        company = loginuserResponse['customerInfo']["cust_company"];
        fax = loginuserResponse['customerInfo']["cust_fax"];
        address1 = loginuserResponse['customerInfo']["cust_address1"];
        address2 = loginuserResponse['customerInfo']["cust_address2"];
        mailID = loginuserResponse['customerInfo']["cust_email"];
        zipCode = loginuserResponse['customerInfo']["cust_zip"];
        phone = loginuserResponse['customerInfo']["cust_phone"];
        phCode =
            loginuserResponse['customerInfo']["cust_countrycode"].toString();
        _selectedCupertinoCountry =
            CountryPickerUtils.getCountryByPhoneCode(phCode);
      });
    }
  }

  edit() async {
    try {
      print("called");
      setState(() {
        isLoading = true;
      });

      var body = json.encode({
        "id": customerId,
        "cust_firstname": firstName,
        "cust_lastname": lastName,
        "cust_company": companyName,
        "cust_phone": phone,
        "cust_countrycode": phCode,
        "cust_address1": address1,
        "cust_address2": address2,
        "cust_fax": fax,
        "cust_zip": zipCode
      });
      print(body);
      print(Constants.editProfile);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.editProfile),
              headers: {
                "Content-Type": "application/json",
              },
              body: body);
      // print(result);
      Map<String, dynamic> response = json.decode(result.body);

      print(response);
      if (response["response"] == "success") {
        final AuthState authState =
            Provider.of<AuthState>(context, listen: false);
        final prefs = await SharedPreferences.getInstance();
        authState.saveLoginUser(
            {"isLogin": true, "customerInfo": response["customerdata"]});
        Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
        Navigator.pop(context, "edited");
      } else {
        Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    phCode = _selectedCupertinoCountry.phoneCode;
    return Form(
      key: _formKey,
      child: Container(
          child: Column(children: [
        Container(
            alignment: Alignment.centerLeft,
            margin: styles.ThemeText.margins,
            child: Text(
              "First name",
              style: styles.ThemeText.inputFieldText,
            )),
        Container(
          width: pageWidth,
          margin: styles.ThemeText.margins,
          child: Theme(
            data: styles.ThemeText.textInputThemeData,
            child: TextFormField(
              initialValue: firstName,
              key: Key(firstName),
              keyboardType: TextInputType.emailAddress,
              style: styles.ThemeText.normalTextStyle,
              decoration: InputDecoration(
                contentPadding: styles.ThemeText.InputTextProperties,
                hintText: 'Enter your first name',
                border: styles.ThemeText.inputOutlineBorder,
              ),
              validator: (value) {
                String pattern = r'(^[a-zA-Z ]*$)';
                RegExp regExp = new RegExp(pattern);
                if (value!.isEmpty) {
                  return 'Please enter first name';
                } else if (!regExp.hasMatch(value)) {
                  return 'Please enter valid first name';
                } else {
                  setState(() {
                    firstName = value;
                  });
                }
                return null;

                //  return null;
              },
            ),
          ),
        ),
        Container(
            alignment: Alignment.centerLeft,
            margin: styles.ThemeText.margins,
            child: Text(
              "Last name",
              style: styles.ThemeText.inputFieldText,
            )),
        Container(
          width: pageWidth,
          margin: styles.ThemeText.margins,
          child: Theme(
            data: styles.ThemeText.textInputThemeData,
            child: TextFormField(
              initialValue: lastName,
              key: Key(lastName),
              keyboardType: TextInputType.emailAddress,
              style: styles.ThemeText.normalTextStyle,
              maxLines: 1,
              decoration: InputDecoration(
                contentPadding: styles.ThemeText.InputTextProperties,
                hintText: 'Enter your last name',
                border: styles.ThemeText.inputOutlineBorder,
              ),
              validator: (value) {
                String pattern = r'(^[a-zA-Z ]*$)';
                RegExp regExp = new RegExp(pattern);
                if (value!.isEmpty) {
                  return 'Please enter last name';
                } else if (!regExp.hasMatch(value)) {
                  return 'Please enter valid last name';
                } else {
                  setState(() {
                    lastName = value;
                  });
                }
                return null;

                //  return null;
              },
            ),
          ),
        ),
        Container(
            alignment: Alignment.centerLeft,
            margin: styles.ThemeText.margins,
            child: Text(
              "Company name",
              style: styles.ThemeText.inputFieldText,
            )),
        Container(
          width: pageWidth,
          margin: styles.ThemeText.margins,
          child: Theme(
            data: styles.ThemeText.textInputThemeData,
            child: TextFormField(
              initialValue: company,
              key: Key(company),
              keyboardType: TextInputType.emailAddress,
              style: styles.ThemeText.normalTextStyle,
              maxLines: 1,
              decoration: InputDecoration(
                contentPadding: styles.ThemeText.InputTextProperties,
                hintText: 'Enter your company name',
                border: styles.ThemeText.inputOutlineBorder,
              ),
              validator: (value) {
                setState(() {
                  companyName = value!;
                });
                return null;
              },
            ),
          ),
        ),
        Container(
            alignment: Alignment.centerLeft,
            margin: styles.ThemeText.margins,
            child: Text(
              "Phone",
              style: styles.ThemeText.inputFieldText,
            )),
        Container(
          margin: styles.ThemeText.margins,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  openModal();
                },
                child: Container(
                    width: pageWidth / 4,
                    margin: EdgeInsets.only(right: 4),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(30.0),
                      ),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        "+" + phCode,
                        maxLines: 1,
                      ),
                    )),
              ),
              Container(
                width: pageWidth / 1.7,
                child: TextFormField(
                  initialValue: phone,
                  key: Key(phone),
                  keyboardType: TextInputType.phone,
                  style: styles.ThemeText.normalTextStyle,
                  maxLines: 1,
                  decoration: InputDecoration(
                    contentPadding: styles.ThemeText.InputTextProperties,
                    hintText: 'Enter your mobile number',
                    border: styles.ThemeText.inputOutlineBorder,
                  ),
                  validator: (value) {
                    String patttern = r'(^(?:[+0]9)?[0-9]{8,15}$)';
                    RegExp regExp = new RegExp(patttern);
                    if (value!.isEmpty) {
                      return 'Please enter phone number';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Please enter valid phone number';
                    } else {
                      setState(() {
                        phone = value;
                      });
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
            alignment: Alignment.centerLeft,
            margin: styles.ThemeText.margins,
            child: Text(
              "Fax",
              style: styles.ThemeText.inputFieldText,
            )),
        Container(
          width: pageWidth,
          margin: styles.ThemeText.margins,
          child: Theme(
            data: styles.ThemeText.textInputThemeData,
            child: TextFormField(
              initialValue: fax,
              key: Key(fax),
              keyboardType: TextInputType.phone,
              style: styles.ThemeText.normalTextStyle,
              maxLines: 1,
              decoration: InputDecoration(
                contentPadding: styles.ThemeText.InputTextProperties,
                hintText: 'Enter your fax',
                border: styles.ThemeText.inputOutlineBorder,
              ),
              validator: (value) {
                String patttern = r'(^(?:[+0]9)?[0-9]{8,15}$)';
                RegExp regExp = new RegExp(patttern);
                if (value!.isNotEmpty && !regExp.hasMatch(value)) {
                  return 'Please enter valid fax number';
                } else {
                  setState(() {
                    fax = value;
                    print(fax);
                  });
                }
                return null;
              },
            ),
          ),
        ),
        Container(
            alignment: Alignment.centerLeft,
            margin: styles.ThemeText.margins,
            child: Text(
              "Address line 1",
              style: styles.ThemeText.inputFieldText,
            )),
        Container(
          width: pageWidth,
          margin: styles.ThemeText.margins,
          child: Theme(
            data: styles.ThemeText.textInputThemeData,
            child: TextFormField(
              initialValue: address1,
              key: Key(address1),
              keyboardType: TextInputType.emailAddress,
              style: styles.ThemeText.normalTextStyle,
              maxLines: 1,
              decoration: InputDecoration(
                contentPadding: styles.ThemeText.InputTextProperties,
                hintText: 'Enter your address line 1',
                border: styles.ThemeText.inputOutlineBorder,
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter address line 1';
                } else {
                  setState(() {
                    address1 = value;
                  });
                }
                return null;
              },
            ),
          ),
        ),
        Container(
            alignment: Alignment.centerLeft,
            margin: styles.ThemeText.margins,
            child: Text(
              "Address line 2",
              style: styles.ThemeText.inputFieldText,
            )),
        Container(
          width: pageWidth,
          margin: styles.ThemeText.margins,
          child: Theme(
            data: styles.ThemeText.textInputThemeData,
            child: TextFormField(
              initialValue: address2,
              key: Key(address2),
              keyboardType: TextInputType.emailAddress,
              style: styles.ThemeText.normalTextStyle,
              maxLines: 1,
              decoration: InputDecoration(
                contentPadding: styles.ThemeText.InputTextProperties,
                hintText: 'Enter your address line 2',
                border: styles.ThemeText.inputOutlineBorder,
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please Enter Address line 2';
                } else {
                  setState(() {
                    address2 = value;
                  });
                }
                return null;
              },
            ),
          ),
        ),
        Container(
            alignment: Alignment.centerLeft,
            margin: styles.ThemeText.margins,
            child: Text(
              "Zipcode",
              style: styles.ThemeText.inputFieldText,
            )),
        Container(
          width: pageWidth,
          margin: styles.ThemeText.margins,
          child: Theme(
            data: styles.ThemeText.textInputThemeData,
            child: TextFormField(
              initialValue: zipCode,
              key: Key(zipCode),
              keyboardType: TextInputType.emailAddress,
              style: styles.ThemeText.normalTextStyle,
              maxLines: 1,
              decoration: InputDecoration(
                contentPadding: styles.ThemeText.InputTextProperties,
                hintText: 'Enter your zipcode',
                border: styles.ThemeText.inputOutlineBorder,
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter zipcode';
                } else {
                  setState(() {
                    zipCode = value;
                  });
                }
                return null;
              },
            ),
          ),
        ),
        // Container(
        //     alignment: Alignment.centerLeft,
        //     margin: styles.ThemeText.margins,
        //     child: Text(
        //       "Postal Code",
        //       style: styles.ThemeText.inputFieldText,
        //     )),
        // Container(
        //   width: pageWidth,
        //   margin: styles.ThemeText.margins,
        //   child: Theme(
        //     data: styles.ThemeText.textInputThemeData,
        //     child: TextFormField(
        //       initialValue: zipCode,
        //       key: Key(zipCode),
        //       keyboardType: TextInputType.phone,
        //       style: styles.ThemeText.normalTextStyle,
        //       maxLines: 1,
        //       decoration: InputDecoration(
        //         contentPadding: styles.ThemeText.InputTextProperties,
        //         hintText: 'Enter Your Postal Code',
        //         border: styles.ThemeText.inputOutlineBorder,
        //       ),
        //       validator: (value) {
        //         String pattern = r'(^[A-Z0-9 ]*$)';
        //         RegExp regExp = new RegExp(pattern);
        //         if (value.isEmpty) {
        //           return 'Please Enter Postal Code';
        //         } else if (!regExp.hasMatch(value)) {
        //           return 'Please enter a valid Postal Code';
        //         } else {
        //           setState(() {
        //             zipCode = value;
        //           });
        //         }
        //         return null;
        //       },
        //     ),
        //   ),
        // ),
        Container(
          width: pageWidth,
          height: 50,
          margin: styles.ThemeText.margin1,
          child: RaisedButton(
            color: Color(Constants.primaryYellow),
            shape: styles.ThemeText.borderRaidus1,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                edit();
              }
            },
            child: isLoading
                ? SpinKitThreeBounce(
                    color: Color(Constants.logocolor),
                    size: 20.0,
                  )
                : Align(
                    child: Text(
                      'Save',
                      style: styles.ThemeText.buttonTextStyles,
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ),
      ])),
    );
  }

  Widget _buildCupertinoItem(Country country) {
    return DefaultTextStyle(
      style: const TextStyle(
        color: CupertinoColors.black,
        fontSize: 16.0,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 8.0),
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(width: 8.0),
          Text("+${country.phoneCode}"),
          SizedBox(width: 8.0),
          Flexible(child: Text(country.name))
        ],
      ),
    );
  }

  Widget phoneCode(Country country) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: const BorderRadius.all(
          const Radius.circular(35.0),
        ),
      ),
      child: Center(child: Text(country.phoneCode)),
    );
  }
}

import '../customicons.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart' as Constants;
import 'package:http/http.dart' as http;

import '../styles.dart' as styles;
import '../widgets/Loader.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:country_pickers/country_pickers.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  bool isLoading = false;
  // @override
  // void initState() {
  //   super.initState();
  // //  _getUsers();
  // }

  @override
  Widget build(BuildContext context) {
    //FlutterStatusbarcolor.setStatusBarColor(Color(Constants.primaryBlack));
    var pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
//        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(CustomIcons.backarrow, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(Constants.primaryBlack),
        elevation: 0,
        title: Text("Register"),
      ),
      body: SingleChildScrollView(
        child: Container(
            color: Color(Constants.primaryBlack),
            child: Column(
              //  crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(50.0),
                          topRight: const Radius.circular(50.0))),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(child: RegistrationForm()),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  bool currentpassHidden = true;
  String firstName = '';
  String lastName = '';
  String companyName = '';
  String phone = '';
  String fax = '';
  String address1 = '';
  String address2 = '';
  String postalcode = '';
  String? errorTextForPassword;
  bool currentpassHidden2 = true;
  bool isLoading = false;
  bool isLoadingTerms = false;
  String userName = '';
  String password = '';
  String password2 = '';
  bool? isSelected = false;
  bool? terms = false;
  String tC = '';
  String findAboutUs = '';
  final List<DropdownMenuItem> items = [];

  Country _selectedCupertinoCountry =
      CountryPickerUtils.getCountryByIsoCode('SG');
  String phCode = '';

  getTerms() async {
    try {
      print("called");

      setState(() {
        isLoadingTerms = true;
      });
      print(Constants.App_url + Constants.terms);
      var result = await http.get(
        Uri.parse(Constants.App_url + Constants.terms),
        headers: {
          "Content-Type": "application/json",
        },
      );
      // var answers = result.body[0]['answers'] as List<Map<String, Object>>;
      for (var u in json.decode(result.body)) {
        print(u);
        setState(() {
          tC = u["termsandconditions"];
        });
      }
      print(tC);

      // print(response);
      // print(response[0]["termsandconditions"]);
      // terms = response[0]["termsandconditions"];
      // data
      setState(() {
        isLoadingTerms = false;
      });
    } catch (e) {
      setState(() {
        isLoadingTerms = false;
      });
    }
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

  _checkEmailAvailablity() async {
    try {
      print("called");
      setState(() {
        isLoading = true;
      });
      var body = json.encode({
        "email": userName,
      });

      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.checkMail),
              headers: {
                "Content-Type": "application/json",
              },
              body: body);
      print(result);
      Map<String, dynamic> response = json.decode(result.body);
      print(response);
      if (response["response"] == "success") {
        _register();
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

  _register() async {
    try {
      print("called");
      setState(() {
        isLoading = true;
      });
      var body = json.encode({
        "cust_firstname": firstName,
        "cust_lastname": lastName,
        "cust_company": companyName,
        "cust_phone": phone,
        "cust_countrycode": phCode,
        "cust_fax": fax,
        "cust_address1": address1,
        "cust_address2": address2,
        "cust_zip": postalcode,
        "cust_newsletter": isSelected! ? 1 : 0,
        "cust_status": 1,
        "howyouknow": findAboutUs,
        "cust_terms_agreed": 1,
        "cust_email": userName,
        "cust_password": password,
      });
      print(body);
      print(Constants.login);
      var result =
          await http.post(Uri.parse(Constants.App_url + Constants.signUp),
              headers: {
                "Content-Type": "application/json",
              },
              body: body);
      // print(result);
      Map<String, dynamic> response = json.decode(result.body);
      //print(response);
      print(findAboutUs);
      if (response["response"] == "success") {
        Fluttertoast.showToast(
          msg: response['message'],
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
        Navigator.pushNamed(context, '/login');
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

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  @override
  void initState() {
    // List<String> data = [
    //   "Google",
    //   "Yahoo",
    //   "YellowPages",
    //   "Friends referral",
    //   "Bing",
    //   "Others"
    // ];

    // for (var u in data) {
    //   {
    //     items.add(DropdownMenuItem(
    //       child: Text(u),
    //       value: u,
    //     ));
    //   }
    // }
    super.initState();
    this.getTerms();
  }

  @override
  Widget build(BuildContext context) {
    var pageWidth = MediaQuery.of(context).size.width;
    phCode = _selectedCupertinoCountry.phoneCode;
    Dialog termsAndConditions = Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
          padding: EdgeInsets.all(10),
          height: 500,
          width: 300,
          child: isLoadingTerms
              ? SpinKitThreeBounce(
                  color: Color(Constants.logocolor),
                  size: 20.0,
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            "Terms and Conditions",
                            style: styles.ThemeText.leftTextstyles,
                          ),
                          Html(
                            data: tC,
                            style: {
                              "html": Style(
                                  color: Colors.black,
                                  textAlign: TextAlign.justify),
                            },
                          ),
                          Container(
                            width: pageWidth,
                            height: 36,
                            child: RaisedButton(
                              color: Color(Constants.primaryYellow),
                              shape: styles.ThemeText.borderRaidus1,
                              onPressed: () {
                                setState(() {
                                  terms = true;
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   Icons.more_horiz,
                                  //   size: 14,
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      'Accept',
                                      style: styles.ThemeText.buttonTextStyles,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )),
    );
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(),
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      validator: (value) {
                        String pattern = r'(^[a-zA-Z ]*$)';
                        RegExp regExp = new RegExp(pattern);
                        if (value!.isEmpty) {
                          return 'Please enter First Name';
                        } else if (!regExp.hasMatch(value)) {
                          return 'Please enter valid First name';
                        } else {
                          setState(() {
                            firstName = value;
                          });
                        }
                        return null;

                        //  return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'First Name',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      validator: (value) {
                        String pattern = r'(^[a-zA-Z ]*$)';
                        RegExp regExp = new RegExp(pattern);
                        if (value!.isEmpty) {
                          return 'Please enter Last Name';
                        } else if (!regExp.hasMatch(value)) {
                          return 'Please enter valid Last name';
                        } else {
                          setState(() {
                            lastName = value;
                          });
                        }
                        return null;

                        //  return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Last Name',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      // validator: (value) {
                      //   String pattern = r'(^[a-zA-Z0-9 ]*$)';
                      //   RegExp regExp = new RegExp(pattern);
                      //   if (value.isEmpty) {
                      //     return 'Please enter Company Name';
                      //   } else if (!regExp.hasMatch(value)) {
                      //     return 'Please enter valid Company name';
                      //   } else {
                      //     setState(() {
                      //       companyName = value;
                      //     });
                      //   }
                      //   return null;

                      //   //  return null;
                      // },
                      keyboardType: TextInputType.emailAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Company Name',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                        width: pageWidth / 1.6,
                        child: TextFormField(
                          validator: (value) {
                            String patttern = r'(^(?:[+0]9)?[0-9]{8,15}$)';
                            RegExp regExp = new RegExp(patttern);
                            if (value!.isEmpty) {
                              return 'Please enter Phone Number';
                            } else if (!regExp.hasMatch(value)) {
                              return 'Please enter valid Phone Number';
                            } else {
                              setState(() {
                                phone = value;
                              });
                            }

                            return null;
                          },
                          keyboardType: TextInputType.phone,
                          style: styles.ThemeText.normalTextStyle,
                          maxLines: 1,
                          decoration: InputDecoration(
                            contentPadding:
                                styles.ThemeText.InputTextProperties,
                            hintText: 'Phone',
                            border: styles.ThemeText.inputOutlineBorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      validator: (value) {
                        String patttern = r'(^(?:[+0]9)?[0-9]{8,15}$)';
                        RegExp regExp = new RegExp(patttern);
                        if (value!.isEmpty) {
                          setState(() {
                            fax = value;
                          });
                        } else if (!regExp.hasMatch(value)) {
                          return 'Please enter valid Fax Number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Fax',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: FlatButton(
                //       onPressed: () => pickplaces(),
                //       child: Text(
                //         'Locate on Map',
                //       )),
                // ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter Address line 1';
                        } else {
                          setState(() {
                            address1 = value;
                          });
                        }
                        return null;
                      },
                      keyboardType: TextInputType.streetAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Address line 1',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
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
                      keyboardType: TextInputType.streetAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Address line 2',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter Postal Code';
                        } else {
                          setState(() {
                            postalcode = value;
                          });
                        }
                        return null;
                      },
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      decoration: InputDecoration(
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Postal Code',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: styles.ThemeText.DefautlLeftRightPadding,
                      margin: const EdgeInsets.only(bottom: 5, top: 10),
                      child: Text(
                          "* Incorrect Postal Codes (Zip Codes) can't be accepted",
                          style: styles.ThemeText.subtitleTinyRed),
                    )),
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: styles.ThemeText.DefautlLeftRightPadding,
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Text(
                          "* Registration without a correct postal code will be deleted",
                          style: styles.ThemeText.subtitleTinyRed),
                    )),
                Container(
                  width: pageWidth,
                  // height: 70,
                  // decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(30),
                  //     border: Border.all(
                  //       color: Color(
                  //           0xFFc1c1c1), //                   <--- border color
                  //       width: 1.0,
                  //     )),
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  // child: SearchableDropdown.single(
                  //   items: items,
                  //   value: findAboutUs,
                  //   hint: "How do you find about us?",
                  //   searchHint: null,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       findAboutUs = value;
                  //     });
                  //   },
                  //   dialogBox: false,
                  //   isExpanded: true,
                  //   menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
                  // ),
                  // child: DropdownButton<dynamic>(
                  //     value: findAboutUs,
                  //     elevation: 16,
                  //     isExpanded: true,
                  //     dropdownColor: Color(Constants.primaryYellow),
                  //     style: styles.ThemeText.buttonTextStyles,
                  //     hint: Text("How you get to know us?"),
                  //     underline: Container(
                  //       height: 0,
                  //     ),
                  //     onChanged: (dynamic value) {
                  //       setState(() {
                  //         findAboutUs = value;
                  //       });
                  //     },
                  //     items: items),
                  child: DropdownSearch<String>(
                    mode: Mode.DIALOG,
                    showSelectedItem: true,
                    validator: (dynamic value) {
                      if (value == null) {
                        findAboutUs = "Others";
                      }
                      return null;
                    },
                    items: [
                      "Google",
                      "Yahoo",
                      "Yellow Pages",
                      "Friends Referral",
                      "Bing",
                      "Others"
                    ],
                    dropdownSearchDecoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.only(left: 20, top: 5, bottom: 5),
                      border: styles.ThemeText.inputOutlineBorder,
                    ),
                    hint: "How you get to know us?",
                    onChanged: (dynamic value) {
                      setState(() {
                        findAboutUs = value;
                        print(findAboutUs);
                      });
                    },
                    showSearchBox: true,
                    searchBoxDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                      hintText: "Search options",
                    ),
                    popupTitle: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(Constants.primaryYellow),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text('Select',
                            style: styles.ThemeText.appbarTextStyles),
                      ),
                    ),
                    popupShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      //padding: styles.ThemeText.DefautlLeftRightPadding,
                      margin: const EdgeInsets.only(top: 10, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                              value: isSelected,
                              activeColor: Color(Constants.primaryBlack),
                              onChanged: (newvalue) {
                                setState(() {
                                  isSelected = newvalue;
                                });
                              }),
                          Text(
                            'I wish to receive newsletter and promotion events.',
                            style: TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,

                            //style: styles.ThemeText.subRedTextStyles,
                          )
                        ],
                      ),
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Login information",
                      style: styles.ThemeText.editProfileText,
                    )),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter Email';
                        } else {
                          if (validateEmail(value)) {
                            setState(() {
                              userName = value;
                            });
                          } else {
                            return 'Incorrect Email Format';
                          }
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline),
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Email Address',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter password';
                        } else if (value.length < 6) {
                          return 'Password must be 6 digits';
                        } else {
                          setState(() {
                            password = value;
                          });
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      obscureText: currentpassHidden,
                      decoration: InputDecoration(
                        errorText: errorTextForPassword,
                        suffixIcon: currentpassHidden
                            ? IconButton(
                                icon: Icon(
                                  Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentpassHidden = false;
                                  });
                                },
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentpassHidden = true;
                                  });
                                },
                              ),
                        prefixIcon: Icon(Icons.lock_outline),
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Password',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: styles.ThemeText.topMargin,
                  child: Theme(
                    data: styles.ThemeText.textInputThemeData,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Enter Password';
                        } else {
                          setState(() {
                            password2 = value;
                          });
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: styles.ThemeText.normalTextStyle,
                      maxLines: 1,
                      obscureText: currentpassHidden2,
                      decoration: InputDecoration(
                        suffixIcon: currentpassHidden2
                            ? IconButton(
                                icon: Icon(
                                  Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentpassHidden2 = false;
                                  });
                                },
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentpassHidden2 = true;
                                  });
                                },
                              ),
                        prefixIcon: Icon(Icons.lock_outline),
                        contentPadding: styles.ThemeText.InputTextProperties,
                        hintText: 'Confirm Password',
                        border: styles.ThemeText.inputOutlineBorder,
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      //padding: styles.ThemeText.DefautlLeftRightPadding,
                      margin: const EdgeInsets.only(top: 10, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                              value: terms,
                              activeColor: Color(Constants.primaryBlack),
                              onChanged: (newvalue) {
                                setState(() {
                                  terms = newvalue;
                                  terms = !terms!;
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          termsAndConditions);
                                });
                              }),
                          Text(
                            'I agree to all terms and conditions',
                            style: TextStyle(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,

                            //style: styles.ThemeText.subRedTextStyles,
                          )
                        ],
                      ),
                    )),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    margin: styles.ThemeText.topMargin,
                    child: RaisedButton(
                      color: Color(Constants.primaryYellow),
                      shape: styles.ThemeText.borderRaidus1,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (password == password2) {
                            if (terms!) {
                              setState(() {
                                errorTextForPassword = null;
                              });

                              _checkEmailAvailablity();
                            } else {
                              Fluttertoast.showToast(
                                msg: "Please accept Terms and Conditions",
                                toastLength: Toast.LENGTH_SHORT,
                                webBgColor: "#e74c3c",
                                timeInSecForIosWeb: 5,
                              );
                            }
                          } else {
                            setState(() {
                              errorTextForPassword = "Password Mismatch";
                            });
                          }

                          // If the form is valid, display a Snackbar.

                        }
                      },
                      child: isLoading
                          ? LoadingWidget()
                          : Text(
                              'Register',
                              style: styles.ThemeText.buttonTextStyles,
                            ),
                    )),
                Container(
                  margin: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center, //Center Row contents vertically,
                    children: <Widget>[
                      Text(
                        "Already have an account? ",
                        style: styles.ThemeText.editProfileText2,
                      ),
                      // style: styles.ThemeText.defaultSubTitle),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: "AvenirLTProRoman",
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold),
                            // style: styles.ThemeText.flatBtnStyles
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
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

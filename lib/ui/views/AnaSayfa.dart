import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:izmir_taksi/data/model/Taksi.dart';
import 'package:izmir_taksi/ui/cubit/AnaSayfa_cubit.dart';
import 'package:izmir_taksi/ui/views/SearchPage.dart';
import 'package:izmir_taksi/ui/views/SettingsPage.dart';
import 'package:izmir_taksi/utils/color.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> with TickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;
  bool _isLoading = false;

  Future<void> _changeloading() async {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  void initState() {
    super.initState();
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    _fetchTaksi();
  }

  Future<void> _fetchTaksi() async {
    await _changeloading();
    await context.read<AnasayfaCubit>().fetchtaksi();
    await _changeloading();
  }

  @override
  void dispose() {
    super.dispose();
    _motionTabBarController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var oran = MediaQuery.of(context);
    var genislik = oran.size.width;
    var uzunluk = oran.size.height;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text(
          "~ Konya Taksi ~",
          style: GoogleFonts.baskervville(
            fontWeight: FontWeight.bold,
            fontSize: genislik / 15,
          ),
        ),
        actions: [
          IconButton(onPressed: (){

          }, icon: FaIcon(FontAwesomeIcons.magnifyingGlassLocation))
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Padding(
          padding: EdgeInsets.only(left: genislik / 35),
          child: Image.asset("assets/taxi.png"),
        ),
      ),
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        initialSelectedTab: "Ana Sayfa",
        labels: const ["Ana Sayfa", "Harita", "Ayarlar"],
        icons: const [Icons.home, Icons.map_outlined, Icons.settings],
        badges: null,
        tabSize: 50,
        tabBarHeight: 55,
        textStyle: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        tabIconColor: yellow2,
        tabIconSize: 28.0,
        tabIconSelectedSize: 26.0,
        tabSelectedColor: yellow,
        tabIconSelectedColor: Colors.black,
        tabBarColor: Colors.black,
        onTabItemSelected: (int value) {
          setState(() {
            _motionTabBarController!.index = value;
          });
        },
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _motionTabBarController,
        children: <Widget>[
          BlocBuilder<AnasayfaCubit, Taksi>(
            builder: (context, taksiData) {
              if (_isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitFadingCircle(
                        color: Colors.yellow,
                        size: 50.0,
                      ),
                      SizedBox(height: uzunluk / 30),
                      Text(
                        'Veriler Yükleniyor...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (taksiData.data != null && taksiData.data!.isNotEmpty) {
                var allContents = taksiData.data!
                    .expand((data) => data.subCategories ?? [])
                    .expand((subCategory) => subCategory.contents ?? [])
                    .toList();
                return ListView.builder(
                  itemCount: allContents.length,
                  itemBuilder: (context, index) {
                    var data = allContents[index];
                    return Card(
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: uzunluk/6,
                          child: Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    "${data.title ?? 'boş title'}",
                                    style: GoogleFonts.rubik(
                                      color: bluee,
                                      fontSize: genislik/20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),


                                ],
                              ),
                              Divider(),

                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: FaIcon(FontAwesomeIcons.locationDot)
                                  ),
                                  Gap(genislik / 100),
                                  Expanded(
                                    child: Text(
                                      "${data.address ?? 'boş title'}",
                                      style: TextStyle(
                                        color: bluee,
                                        fontSize: genislik/25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      softWrap: true,

                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Searchpage()));
                                      },
                                      icon: FaIcon(FontAwesomeIcons.mapLocationDot)
                                  ),
                                ],
                              )




                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text(
                    "Veriler yüklenemedi.",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                );
              }
            },
          ),
          const Searchpage(),
          const Settingspage(),
        ],
      ),
    );
  }
}

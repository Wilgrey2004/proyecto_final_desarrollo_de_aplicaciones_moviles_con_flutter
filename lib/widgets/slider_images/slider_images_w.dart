import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarrucelImages extends StatefulWidget {
  const CarrucelImages({super.key});

  @override
  State<CarrucelImages> createState() => _CarrucelImagesState();
}

class _CarrucelImagesState extends State<CarrucelImages> {
  // final List<String> imagesUrl = List.generate(
  //   10,
  //   (i) => "https://i.postimg.cc/YSFPTJjL/image.png",
  // );

  final List<String> imagesUrl = [
    "https://i.postimg.cc/YSFPTJjL/image.png",
    "https://i.postimg.cc/pXQZgzfC/image.png",
    "https://i.postimg.cc/jj24w1G3/image.png",
    "https://i.postimg.cc/3wqCgBh8/image.png",
    "https://i.postimg.cc/d3jySRbT/image.png",
  ];

  int _currentImg = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 40),
          CarouselSlider.builder(
            carouselController: _controller,
            itemCount: imagesUrl.length,
            itemBuilder: (context, index, realIndex) {
              final url = imagesUrl[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (c, e, s) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              );
            },
            options: CarouselOptions(
              height: 320,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              viewportFraction: 0.85,
              onPageChanged: (index, reason) =>
                  setState(() => _currentImg = index),
            ),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imagesUrl.asMap().entries.map((entry) {
              final idx = entry.key;
              return GestureDetector(
                onTap: () => _controller.animateToPage(idx),
                child: Container(
                  width: _currentImg == idx ? 12 : 8,
                  height: _currentImg == idx ? 12 : 8,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImg == idx ? Colors.green : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _controller.previousPage(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('< Anterior'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _controller.nextPage(),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('siguiente >'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

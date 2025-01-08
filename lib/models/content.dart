class Content{
  final String name;
  final int id;
  final String desc;
  final String image;
  final String link;

   double? enrollment_price;
   String? firstDate;
   String? place;
   DateTime? update_at;

  final String content_category ;

  final bool? isLike;

  Content({required this.name, required this.id, required this.desc, required this.image,  this.isLike, required this.link, required this.content_category, this.enrollment_price, this.firstDate, this.place, this.update_at});

 // Convert a Content object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'desc': desc,
      'image': image,
      'link': link,
      'isLike': isLike,
      'content_category':content_category
    };
  }

   Map<String, dynamic> toGPTMap() {
    return {
      'name': name,
      //'id': id,
      'desc': desc,
      
     
      'enrollment_price':enrollment_price,
      'place': place,
      'first_date':firstDate
    };
  }



  // Create a Content object from a Map
  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      name: map['name'] as String,
      id: map['id'] as int,
      desc: (map['desc']??'') as String,
      image:( map['image']??'') as String,
      link: (map['link']??'') as String,
      isLike: map['isLike'] != null ? map['isLike'] as bool : null,
      content_category: (map['content_type_id']??'').toString(),
      enrollment_price: double.tryParse(map['enrollment_price']??""),
      firstDate: map['first_date'],
      place: map['place'],
      update_at: DateTime.tryParse(map['updated_at']??'') 

    );
  }
  
}
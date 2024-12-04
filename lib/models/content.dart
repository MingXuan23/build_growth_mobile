class Content{
  final String name;
  final int id;
  final String desc;
  final String image;
  final String link;

  final String content_category ;

  final bool? isLike;

  Content({required this.name, required this.id, required this.desc, required this.image,  this.isLike, required this.link, required this.content_category});

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

  // Create a Content object from a Map
  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      name: map['name'] as String,
      id: map['id'] as int,
      desc: (map['desc']??'') as String,
      image:( map['image']??'') as String,
      link: (map['link']??'') as String,
      isLike: map['isLike'] != null ? map['isLike'] as bool : null,
      content_category: (map['content_type_id']??'').toString()
    );
  }
  
}
class MediaContent {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> genres;
  final String contentType; // movie, tvShow, etc.
  final String? trailerUrl;
  final double? rating;
  final String? year;
  final String? ageRating;

  MediaContent({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.genres,
    required this.contentType,
    this.trailerUrl,
    this.rating,
    this.year,
    this.ageRating,
  });

  // Sample data for demo purposes
  static List<MediaContent> getSampleFeaturedContent() {
    return [
      MediaContent(
        id: '1',
        title: 'Severance',
        description: 'Don\'t miss the most talked-about show of the year.',
        imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/WTDZpzkQlaatpb1X0e0HWA/1679x945sr.webp',
        genres: ['Drama', 'Thriller', 'Mystery'],
        contentType: 'tvShow',
        rating: 8.7,
        year: '2022',
        ageRating: 'TV-MA',
      ),
      MediaContent(
        id: '2',
        title: 'Ted Lasso',
        description: 'A small-time football coach is hired to coach a professional soccer team.',
        imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/JRJI_0V8OHOKWC-UAZL3vQ/1679x945.webp',
        genres: ['Comedy', 'Drama', 'Sports'],
        contentType: 'tvShow',
        rating: 8.8,
        year: '2020',
        ageRating: 'TV-MA',
      ),
      MediaContent(
        id: '3',
        title: 'The Morning Show',
        description: 'An inside look at the lives of the people who help America wake up in the morning.',
        imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/cyRwgQS8dHaiRNSzJEFR9Q/1679x945sr.webp',
        genres: ['Drama'],
        contentType: 'tvShow',
        rating: 8.2,
        year: '2019',
        ageRating: 'TV-MA',
      ),
      MediaContent(
        id: '4',
        title: 'Pachinko',
        description: 'Based on the New York Times bestseller, this sweeping saga chronicles the hopes and dreams of a Korean immigrant family.',
        imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/KS0pkmrVEdO4uYZA5CpRZA/1679x945sr.webp',
        genres: ['Drama'],
        contentType: 'tvShow',
        rating: 8.5,
        year: '2022',
        ageRating: 'TV-MA',
      ),
      MediaContent(
        id: '5',
        title: 'Foundation',
        description: 'Based on the award-winning novels by Isaac Asimov, Foundation chronicles a band of exiles on their monumental journey to save humanity.',
        imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/6tJixlNrQCUNXOfLjFs-zw/1679x945sr.webp',
        genres: ['Sci-Fi', 'Fantasy', 'Drama'],
        contentType: 'tvShow',
        rating: 7.4,
        year: '2021',
        ageRating: 'TV-14',
      ),
    ];
  }

  // Sample movies
  static List<MediaContent> getSampleMovies() {
    return [
      MediaContent(
        id: '6',
        title: 'CODA',
        description: 'As a CODA (Child of Deaf Adults), Ruby is the only hearing person in her deaf family.',
        imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/QokNbifNbfRQNkAT2QJ57w/1679x945sr.webp',
        genres: ['Drama', 'Music'],
        contentType: 'movie',
        rating: 8.1,
        year: '2021',
        ageRating: 'PG-13',
      ),
      MediaContent(
        id: '7',
        title: 'The Tragedy of Macbeth',
        description: 'Denzel Washington and Frances McDormand star in Joel Coen\'s bold and fierce adaptation.',
        imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/3GZ-bT8oPXfy-dC8OwgPVA/1679x945sr.webp',
        genres: ['Drama', 'Thriller'],
        contentType: 'movie',
        rating: 7.1,
        year: '2021',
        ageRating: 'R',
      ),
      MediaContent(
        id: '8',
        title: 'Finch',
        description: 'Tom Hanks is Finch, a man who embarks on a moving journey to find a new home for his unlikely family.',
        imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/rbA884KyD1XMkjwmG8hbcw/1679x945sr.webp',
        genres: ['Sci-Fi', 'Drama'],
        contentType: 'movie',
        rating: 6.9,
        year: '2021',
        ageRating: 'PG-13',
      ),
    ];
  }

  // Sample TV shows
  static List<MediaContent> getSampleTVShows() {
    return [
      MediaContent(
        id: '9',
        title: 'For All Mankind',
        description: 'Imagine a world where the global space race never ended.',
        imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/I_H9RPHRBIaD0XYQNCx2uw/1679x945sr.webp',
        genres: ['Sci-Fi', 'Drama'],
        contentType: 'tvShow',
        rating: 8.0,
        year: '2019',
        ageRating: 'TV-MA',
      ),
      MediaContent(
        id: '10',
        title: 'Servant',
        description: 'From M. Night Shyamalan, a new psychological thriller.',
        imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/_ODFuW9Im8U9H-LVnS_YAg/1679x945sr.webp',
        genres: ['Thriller', 'Horror'],
        contentType: 'tvShow',
        rating: 7.5,
        year: '2019',
        ageRating: 'TV-MA',
      ),
    ];
  }
} 
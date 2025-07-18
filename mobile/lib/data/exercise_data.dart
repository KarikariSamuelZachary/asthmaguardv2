import '../models/exercise.dart';

final Map<String, Map<String, List<Exercise>>> workoutData = {
  'beginner': {
    'warmup': [
      Exercise(
        id: 'bwu1',
        title: 'Neck Rolls',
        description: 'Gently roll your neck to warm up and release tension.',
        videoUrl: 'https://www.youtube.com/watch?v=2L2lnxIcNmo',
        duration: 60,
        calories: 10,
      ),
      Exercise(
        id: 'bwu2',
        title: 'Shoulder Circles',
        description: 'Loosen up your shoulders with slow circles.',
        videoUrl: 'https://www.youtube.com/watch?v=QZEqB6wUPxQ',
        duration: 60,
        calories: 12,
      ),
    ],
    'cardio': [
      Exercise(
        id: 'bc1',
        title: 'March in Place',
        description: 'Light cardio to get your heart rate up.',
        videoUrl: 'https://www.youtube.com/watch?v=F6PHZ6cQEPQ',
        duration: 120,
        calories: 30,
      ),
    ],
    'strength': [
      Exercise(
        id: 'bs1',
        title: 'Wall Push-Ups',
        description: 'Strengthen your upper body with wall push-ups.',
        videoUrl: 'https://www.youtube.com/watch?v=QnQe0xW_JY4',
        duration: 90,
        calories: 20,
      ),
    ],
    'hiit': [
      Exercise(
        id: 'bh1',
        title: 'Jumping Jacks',
        description: 'A classic HIIT move for full-body activation.',
        videoUrl: 'https://www.youtube.com/watch?v=c4DAnQ6DtF8',
        duration: 60,
        calories: 15,
      ),
    ],
    'cooldown': [
      Exercise(
        id: 'bcd1',
        title: 'Seated Forward Bend',
        description: 'Cool down and stretch your back and legs.',
        videoUrl: 'https://www.youtube.com/watch?v=8BcPHWGQO44',
        duration: 90,
        calories: 8,
      ),
    ],
  },
  'intermediate': {
    'warmup': [
      Exercise(
        id: 'iwu1',
        title: 'Arm Swings',
        description: 'Dynamic arm swings to prep for exercise.',
        videoUrl: 'https://www.youtube.com/watch?v=QZEqB6wUPxQ',
        duration: 60,
        calories: 15,
      ),
    ],
    'cardio': [
      Exercise(
        id: 'ic1',
        title: 'High Knees',
        description: 'Increase your heart rate with high knees.',
        videoUrl: 'https://www.youtube.com/watch?v=8opcQdC-V-U',
        duration: 90,
        calories: 40,
      ),
    ],
    'strength': [
      Exercise(
        id: 'is1',
        title: 'Bodyweight Squats',
        description: 'Build leg strength with squats.',
        videoUrl: 'https://www.youtube.com/watch?v=aclHkVaku9U',
        duration: 120,
        calories: 35,
      ),
    ],
    'hiit': [
      Exercise(
        id: 'ih1',
        title: 'Mountain Climbers',
        description: 'A HIIT move for core and cardio.',
        videoUrl: 'https://www.youtube.com/watch?v=nmwgirgXLYM',
        duration: 60,
        calories: 20,
      ),
    ],
    'cooldown': [
      Exercise(
        id: 'icd1',
        title: 'Child’s Pose',
        description: 'Relax and stretch your back.',
        videoUrl: 'https://www.youtube.com/watch?v=8BcPHWGQO44',
        duration: 90,
        calories: 10,
      ),
    ],
  },
  'advanced': {
    'warmup': [
      Exercise(
        id: 'awu1',
        title: 'Dynamic Lunges',
        description: 'Warm up with dynamic lunges.',
        videoUrl: 'https://www.youtube.com/watch?v=QZEqB6wUPxQ',
        duration: 90,
        calories: 20,
      ),
    ],
    'cardio': [
      Exercise(
        id: 'ac1',
        title: 'Burpees',
        description: 'Intense cardio with burpees.',
        videoUrl: 'https://www.youtube.com/watch?v=TU8QYVW0gDU',
        duration: 90,
        calories: 60,
      ),
    ],
    'strength': [
      Exercise(
        id: 'as1',
        title: 'Push-Ups',
        description: 'Classic push-ups for upper body strength.',
        videoUrl: 'https://www.youtube.com/watch?v=_l3ySVKYVJ8',
        duration: 120,
        calories: 40,
      ),
    ],
    'hiit': [
      Exercise(
        id: 'ah1',
        title: 'Tuck Jumps',
        description: 'Explosive HIIT with tuck jumps.',
        videoUrl: 'https://www.youtube.com/watch?v=QgaB2bXyQJ8',
        duration: 60,
        calories: 25,
      ),
    ],
    'cooldown': [
      Exercise(
        id: 'acd1',
        title: 'Supine Twist',
        description: 'Cool down with a gentle twist.',
        videoUrl: 'https://www.youtube.com/watch?v=8BcPHWGQO44',
        duration: 90,
        calories: 12,
      ),
    ],
  },
};

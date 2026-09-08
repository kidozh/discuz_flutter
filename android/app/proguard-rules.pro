# Room 2.2.5's consumer rule keeps database classes but omits their constructors.
# R8 full mode requires this explicit constructor for Room's reflective creation
# of WorkDatabase_Impl during WorkManager's startup provider initialization.
-keep class * extends androidx.room.RoomDatabase {
    public <init>();
}

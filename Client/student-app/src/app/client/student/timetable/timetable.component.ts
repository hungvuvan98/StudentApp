import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { MainService } from '../../../shared/services/main.service';
import { CourseRegisterService } from '../course-register/course-register.service';

@Component({
  selector: 'app-timetable',
  templateUrl: './timetable.component.html',
  styleUrls: ['./timetable.component.css'],
  providers:[CourseRegisterService]
})
export class TimetableComponent implements OnInit {

timetable:any[];
semester: any;
  constructor(private authService:AuthService,private mainService:MainService,private courseService:CourseRegisterService) { }

  ngOnInit(): void {

    this.authService.getUserId().subscribe(user=>{
      this.mainService.getNewestSemester().subscribe(semester=>{
        this.semester=semester;
        this.courseService.GetRegisteredClassByStudentId(semester,user).subscribe(res=>{
          console.log(res);

            this.timetable=res;
        });
      })
    });
  }

}

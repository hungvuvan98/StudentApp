import { Component, OnInit } from '@angular/core';
import { NotificationService } from '../../../shared/services/Notification/Notification.service';
import { CourseListService } from './course-list.service';

@Component({
  selector: 'app-course-list',
  templateUrl: './course-list.component.html',
  styleUrls: ['./course-list.component.css'],
  providers:[CourseListService]
})
export class CourseListComponent implements OnInit {

  page: number = 1;
  courses:any[];
  courseTemp:any[];
  departments:any[];
  constructor(private courseService:CourseListService,private noticeService:NotificationService) { }

  ngOnInit(): void {
    this.courses=null;
    this.courseService.GetDepartments().subscribe(departs=>{
      this.departments=departs;
    });
  }

  GetCourseByDepartment(departmentId:string):void{
    this.courseService.GetCourse(departmentId).subscribe(res=>{
        this.courses=res;
        this.courseTemp=res;
    });
  }

  onSelectChange(departmentId:string){

    this.courseService.GetCourse(departmentId).subscribe(res=>{
        this.courses=res;
        this.courseTemp=res;
    });
  }
  search(searchString:string,departmentId:string){
    if(searchString!=''){
      this.courses=this.courseTemp.filter(x=>x.title.replace(/\s/g,'').toUpperCase().includes(searchString.replace(/\s/g,'').toUpperCase())
                                            || x.courseId.replace(/\s/g,'').toUpperCase()==searchString.replace(/\s/g,'').toUpperCase()
                                          );
      if(this.courses.length==0){
        this.courses=this.courseTemp;
      }
    }
    else{
      this.onSelectChange(departmentId);
    }
  }
}

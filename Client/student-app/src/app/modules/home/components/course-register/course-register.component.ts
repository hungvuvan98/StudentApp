import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../../common/services/auth/auth.service';
import { Router } from '@angular/router';
import { CourseClassService } from '../../services/course-class.service';
import { StudentService } from '../../services/student.service';
import { WarningService } from '../../services/warning.service';
import { ListClass } from '../../models/list-class';
import { NotificationService } from '../../../../common/notification.service';
import { MainService } from '../../../../common/services/main.service';


@Component({
  selector: 'app-course-register',
  templateUrl: './course-register.component.html',
  styleUrls: ['./course-register.component.css'],
  providers:[CourseClassService,WarningService]
})
export class CourseRegisterComponent implements OnInit {

  studentId: string
  className: string
  studentName:string
  maxRegister: number
  listRegisteredClass:ListClass[]
  listtemp:ListClass[]
  totalCredit:number=0
  isAllChecked =false
  semester:string
  constructor(private authService:AuthService,
              private classService:CourseClassService,
              private studentService: StudentService,
              private warnService:WarningService,
              private noticeService: NotificationService,
              private mainService:MainService,
              private route: Router) {
               }

  ngOnInit(): void {
    if(this.authService.isAuthenticated()==false){
      this.route.navigate(['/login'])
    }
    else{
    this.studentId=this.authService.getStudentId()
    this.classService.GetClassNameByStudent(this.studentId).subscribe(res=>{
       this.className=res
    })
    this.GetInfo(this.studentId)
    this.GetLevel(this.studentId)
    
    this.mainService.getNewestSemester().subscribe(res=> {
      this.semester=res
      this.GetRegisteredClass(this.semester,this.studentId)   
    })
    }   
  }

  GetLevel(studentId){
    this.warnService.GetLevel(studentId).subscribe(res=>{
      if(res==0|| res==-1) this.maxRegister=24
      else if(res==1) this.maxRegister=18
      else if(res==2) this.maxRegister=14
      else this.maxRegister=0
    })
  }
  GetInfo(studentId){
    this.studentService.GetInfo(studentId).subscribe(res=>{
      this.studentName=res.name
    })
  }

  RegisterClassTemp(classId){
    this.classService.RegisterClassTemp(classId,this.semester).subscribe(res=>{      
        if(this.listRegisteredClass.find(x=>x.secId==res.secId)==undefined){
          this.listRegisteredClass.push(res)
          this.noticeService.show('info',`Đã thêm lớp ${res.secId} - ${res.title} vào hàng chờ đăng ký`)       
        }
        else{
          this.noticeService.show('warning',`Lớp ${res.secId} - ${res.title} (${res.courseId}) đã tồn tại`) 
        }      
        this.TotalCredit(this.listRegisteredClass)
    })
  }
  
  TotalCredit(data:ListClass[]){
    this.totalCredit=0
    for (let i = 0; i < data.length; i++) {
      this.totalCredit += data[i].credit
    }
  }
  SendRegister(data){
    this.studentService.SendRegister(data).subscribe(res=>{
      if(res[0]!=0)
         this.noticeService.show('success',`Có ${res[0]} lớp được thêm mới `)
      if(res[1]!=0)
         this.noticeService.show('error',`Có ${res[1]} lớp bị xóa `)
      this.GetRegisteredClass(this.semester,this.studentId);
    })
  }

  GetRegisteredClass(semester,studentId){
    this.classService.GetRegisteredClassByStudentId(semester,studentId).subscribe(res=>{
        this.listRegisteredClass=res
        this.TotalCredit(this.listRegisteredClass)
    })
  }

  isAll(){
    this.listRegisteredClass.length=0
    console.log(this.listRegisteredClass)
  }
 listemp: Array<ListClass>
  isCheckedById(data:string){
     for (let index = 0; index < this.listRegisteredClass.length; index++) {
        if(this.listRegisteredClass[index].secId==data)
          this.listRegisteredClass.splice(index,1)             
      }
  }
}

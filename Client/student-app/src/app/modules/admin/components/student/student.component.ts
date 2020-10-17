import { Component, OnInit} from '@angular/core';
import { DecimalPipe } from '@angular/common';
import {StudentService} from'../../services/student/student.service';
import { Student } from '../../models/student/student';
import { NotificationService } from '../../../../common/notification.service';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { StudentDetail } from '../../models/student/student-detail';
import {FormGroup, FormBuilder, Validators} from '@angular/forms';
import { ResultLearning } from '../../models/student/resultlearning';

@Component({
  selector: 'app-student',
  templateUrl: './student.component.html',
  styleUrls: ['./student.component.css'],
  providers: [StudentService]
})

export class StudentComponent implements OnInit {
   
  year: string[]
  departmentName: string[]
  className: string[]
  studentDetail: StudentDetail[]
  filterForm: FormGroup
  students: Student[] 
  infor: StudentDetail
  resultLearning: ResultLearning[]
  config: any

  constructor(public studentService: StudentService,
              private noticeService:NotificationService,
              private modalService: NgbModal,
              private fb: FormBuilder
            ) {
       this.filterForm = this.fb.group({
            year_: [''],
            dept_: [''],
            class_: ['']
           }) 
        this.addStudentForm= this.fb.group({
            id: ['',Validators.required],
            name: ['',Validators.required],
            email:[''],
            password: ['',Validators.required],
            birthDay: ['',Validators.required],          
            address: [''],
            cardId :['',Validators.required],
            birthplace: [''],
            avatar: [''],
            createdYear: ['',Validators.required],          
            studentClassName: ['',Validators.required],
            departmentName: ['',Validators.required]           
        })
        this.addStudentForm.get('departmentName').valueChanges.subscribe(res=>{
          if(this.addStudentForm.get('createdYear').value!=''){
            this.GetClassName(this.addStudentForm.get('createdYear').value,res)
          }
          else {
            this.noticeService.show('warning','Chọn năm')
          }
        })
        this.addStudentForm.get('createdYear').valueChanges.subscribe(res=>{
          if(this.addStudentForm.get('departmentName').value!=''){
            this.GetClassName(res,this.addStudentForm.get('departmentName').value)
          }    
        })
       this.GetStudent()
       this.PageAction(event)
       
 }

  ngOnInit(): void { 
    
  } 

  SearchId(term: string){
    if(term!=''){
       var st : Student
       st = this.students.find(x=>x.id==term)
       if(st!= undefined){
         this.students.length = 0
         this.students.push(st)
       }
    }
    else{
        this.GetStudent()
    }
  }

  GetStudent() {
    this.studentService.GetStudent().subscribe(res=>{
        this.students = res 
        //filter year and dept_name
        this.year = [...new Set(res.map(item => item.createdYear))]
        this.departmentName=[...new Set(res.map(item => item.departmentName))]    
    }); 
}

  PageAction(event){
    this.config = {
      itemsPerPage: 20,
      currentPage: 1,
      totalItems: this.students?.length
    }
    // call if page changed
    this.config.currentPage = event
  }

  GetClassName(year,dept_name){
    return this.studentService.GetClassName(year,dept_name).subscribe( res=>{
      this.className=res
    }        
  )}

  FilterData(obj?:object[]){
  var year=obj['year_'],clName=obj['class_'],dept=obj['dept_'] 

  if(year!='' && dept!=''){
    this.GetClassName(year,dept)
  }
  this.studentService.FilterStudent(year,dept,clName).subscribe( res=> {
    this.students=res
  }) 
  }

  EditStudent(id){
  this.studentService.GetDetail(id).subscribe(res=> {
    this.studentDetail=res
    this.infor= res[0]
    if(res.length==0) this.noticeService.show('info','Khong co du lieu cua sv ')
  })
  }

  
  DeleteStudent(id){
    this.studentService.DeleteStudent(id).subscribe(res=>{
      this.noticeService.show('success',`${res}`)
    })
  }

  // code of studentdetail
   
  GetResultLearning(id){

    this.studentService.GetResultLearning(id).subscribe(res=>{
        this.resultLearning = res
    })
  }

  ShowDetail(detailStudent){
    this.modalService.open(detailStudent, { scrollable: true,size: 'xl' })
  }

  // code of add new student
  addStudentForm: FormGroup

  ShowAddStudent(newStudent){
    this.modalService.open(newStudent, { scrollable: true,size: 'lg' })
     //get department
     this.studentService.GetDepartment().subscribe(res=>{
      this.departmentName=res
    })
  }

  AddStudent(){
    var birthDay= this.addStudentForm.get('birthDay').value
    birthDay= birthDay['year'] + '-' + birthDay['month'] + '-' + birthDay['day']
    this.addStudentForm.controls.birthDay.setValue(birthDay);
    this.studentService.AddStudent(this.addStudentForm.value).subscribe(res=>{
        this.noticeService.show('success','Thêm thành công 1 bản ghi')
        this.GetStudent()
        //this.addStudentForm.reset()
    })
  }

}

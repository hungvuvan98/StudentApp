import { Component, OnInit } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { MainService } from '../../../shared/services/main.service';
import { ClassListService } from './class-list.service';

@Component({
  selector: 'app-class-list',
  templateUrl: './class-list.component.html',
  styleUrls: ['./class-list.component.css'],
  providers:[ClassListService]
})
export class ClassListComponent implements OnInit {
  
  listClass: any[]
  detailClass:any
  config: any
  message:string
  semester:string
  constructor(private classService:ClassListService,
              private mainService:MainService,
              private modalService: NgbModal) {
    this.PageAction(event)
   }

  ngOnInit(): void {
    this.message=undefined
    this.mainService.getNewestSemester().subscribe(res=>{
      this.semester=res
      this.GetAll(this.semester)
      
    })  
  }
  GetAll(semester){
    this.classService.GetAll(semester).subscribe(res=>{
      this.listClass=res
      console.log(res)
    })
  }

  Detail(secId){
    this.detailClass=this.listClass.find(x=>x.secId==secId)
  }

  SearchBySecId(secId: string){
    if(secId!=''){      
        var st : any[]
        st = this.listClass.filter(x=>x.secId==secId)                             
        if(st.length!=0){
          this.listClass.length = 0
          this.listClass=st
          this.message=` Có ${st.length} bản ghi được tìm thấy`         
        }     
    }
    else{
        this.ngOnInit()
    }
  }
  SearchByCourseId(courseId: string){
    if(courseId!=''){      
        var st : any[]
        st = this.listClass.filter(x=>x.courseId==courseId)                             
        if(st.length!=0){
          this.listClass.length = 0
          this.listClass=st
          this.message=` Có ${st.length} bản ghi được tìm thấy`    
        }     
    }
    else{
        this.ngOnInit()
    }
  }
  SearchByCredit(credit){
    if(credit!=''){      
        var st : any[]
        st = this.listClass.filter(x=>x.credit==parseInt(credit))                             
        if(st.length!=0){
          this.listClass.length = 0
          this.listClass=st
          this.message=` Có ${st.length} bản ghi được tìm thấy`    
        }     
    }
    else{
        this.ngOnInit()
    }
  }
  SearchByDepartment(dept){
    if(dept!=''){      
        var st : any[]
        st = this.listClass.filter(x=>x.name.toLowerCase().includes(dept.toLowerCase()))                             
        if(st.length!=0){
          this.listClass.length = 0
          this.listClass=st
          this.message=` Có ${st.length} bản ghi được tìm thấy`    
        }     
    }
    else{
        this.ngOnInit()
    }
  }
  SearchByTitle(title){
    if(title!=''){      
        var st : any[]
        st = this.listClass.filter(x=>x.title.toLowerCase().includes(title.toLowerCase()))                             
        if(st.length!=0){
          this.listClass.length = 0
          this.listClass=st
          this.message=` Có ${st.length} bản ghi được tìm thấy`    
        }     
    }
    else{
        this.ngOnInit()
    }
  }
  

  PageAction(event){
    this.config = {
      itemsPerPage: 20,
      currentPage: 1,
      totalItems: this.listClass?.length
    }
    // call if page changed
    this.config.currentPage = event
  }

  ShowDetailClass(detail){
    this.modalService.open(detail, { scrollable: true,size: 'xl' })
  }
}

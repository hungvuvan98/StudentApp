import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import {environment} from '../../../../environments/environment'
import { PostModel } from '../../../shared/model/post';
@Injectable()
export class PostService {

  constructor(private http: HttpClient) { }
  
  getPostByCategory(categoryId): Observable<PostModel[]>{
    const url = environment.apiUrl + '/post/GetByCategory/'+ categoryId;
    return this.http.get<PostModel[]>(url);
  }
  getPostById(postId): Observable<PostModel>{
    const url = environment.apiUrl + '/post/GetById/' + postId;
    return this.http.get<PostModel>(url);
  }

  getAllCategory(): Observable<any[]>{
    const url = environment.apiUrl + '/post/GetAllCategory';
    return this.http.get<any[]>(url);
  }
}
